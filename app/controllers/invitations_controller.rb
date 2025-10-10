class InvitationsController < ApplicationController
  load_and_authorize_resource :collection
  load_and_authorize_resource :invitation, through: :collection, shallow: true, except: [ :index, :accept, :decline ]
  load_resource :invitation, only: [ :accept, :decline ]

  # GET /invitations or /invitations.json
  def index
    @invitations = @collection.subtree_invitations
    @pending_invitations = @invitations.where(status: :pending)
    @accepted_invitations = @invitations.where(status: :accepted)
    @declined_invitations = @invitations.where(status: :declined)
  end

  # GET /invitations/1 or /invitations/1.json
  def show
  end

  # GET /invitations/new
  def new
  end

  # GET /invitations/1/edit
  def edit
  end

  # POST /invitations or /invitations.json
  def create
    respond_to do |format|
      if @invitation.save
        InvitationMailer.invitation_created(@invitation).deliver_later
        format.html { redirect_to @invitation, notice: "Invitation was successfully created." }
        format.json { render :show, status: :created, location: @invitation }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @invitation.errors, status: :unprocessable_entity }
      end
    end
  end

  def new_batch
    @user_info = ""
    @message = ""
  end

  def create_batch
    @user_info = params[:user_info]
    @message = params[:message]
    invitations = []
    @user_info.split(/[\n,;]+/).each do |user_string|
      name_email_regex = /(.+)\s+(.+)\s+<(.+)>/
      if user_string.strip.match(name_email_regex)
        first_name, last_name, email = user_string.match(name_email_regex).captures
        user_id = get_user_id(email, first_name, last_name, "")
      else
        flash.now[:alert] = "Could not parse invitation name/email: `#{user_string}`."
        render :new_batch, status: :unprocessable_entity
        return
      end
      invitations << @collection.invitations.new(user_id: user_id, message: @message)
    end

    invalid_invitations = invitations.reject(&:valid?)
    if invalid_invitations.any?
      flash.now[:alert] = "Some invitations could not be created: #{invalid_invitations.map { |inv| inv.errors.full_messages.join(', ') }.join('; ')}"
      render :new_batch, status: :unprocessable_entity
      return
    end

    invitations.each_with_index do |invitation, i|
      invitation.save!
      InvitationMailer.invitation_created(invitation).deliver_later(wait: i.seconds)
    end
    redirect_to collection_invitations_path(@collection), notice: "Invitations sent."
  end

  # PATCH/PUT /invitations/1 or /invitations/1.json
  def update
    respond_to do |format|
      if @invitation.update(invitation_params)
        format.html { redirect_to @invitation, notice: "Invitation was successfully updated." }
        format.json { render :show, status: :ok, location: @invitation }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @invitation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /invitations/1 or /invitations/1.json
  def destroy
    collection = @invitation.collection
    @invitation.destroy!

    respond_to do |format|
      format.html { redirect_to collection_invitations_path(collection), status: :see_other, notice: "Invitation was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def accept
    authorize! :respond_to, @invitation
    @invitation.update! status: :accepted
    redirect_to @invitation, notice: "Invitation accepted."
  end

  def decline
    authorize! :respond_to, @invitation
    @invitation.update! status: :declined
    redirect_to @invitation, notice: "Invitation declined."
  end

  private
    # Only allow a list of trusted parameters through.
    def invitation_params
      ps = params.expect(invitation: [
        :collection_id, :message, :user_email, :user_first_name,
        :user_last_name, :user_affiliation, :status, :user_id
      ])
      if ps[:user_id].blank?
        ps[:user_id] = get_user_id(
          ps[:user_email], ps[:user_first_name], ps[:user_last_name], ps[:user_affiliation]
        )
      end
      ps.except(:user_email, :user_first_name, :user_last_name, :user_affiliation)
    end

    def get_user_id(email, first_name, last_name, affiliation)
      user = User.find_by(email: email.downcase.strip)
      return user if user.present?
      User.create!(
        email: email.downcase.strip,
        first_name: first_name.strip,
        last_name: last_name.strip,
        affiliation: affiliation.strip.present? ? affiliation.strip : "Unaffiliated",
        position: "N/A",
        position_type: 4,
      ).id
    end
end
