class InvitationsController < ApplicationController
  load_and_authorize_resource :collection
  load_and_authorize_resource :invitation, through: :collection, shallow: true

  # GET /invitations or /invitations.json
  def index
    @invitations = Invitation.all
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
    @profiles = ""
    @message = ""
  end

  def create_batch
    @profiles = params[:profiles]
    @message = params[:message]
    invitations = []
    @profiles.split(/[\n,;]+/).each do |profile_string|
      name_email_regex = /(.+)\s+(.+)\s+<(.+)>/
      if profile_string.strip.match(name_email_regex)
        first_name, last_name, email = profile_string.match(name_email_regex).captures
        profile_id = get_profile_id(email, first_name, last_name)
      else
        flash.now[:alert] = "Could not parse invitation name/email: `#{profile_string}`."
        render :new_batch, status: :unprocessable_entity
        return
      end
      invitations << @collection.invitations.new(profile_id: profile_id, message: @message)
    end

    invalid_invitations = invitations.reject(&:valid?)
    if invalid_invitations.any?
      flash.now[:alert] = "Some invitations could not be created: #{invalid_invitations.map { |inv| inv.errors.full_messages.join(', ') }.join('; ')}"
      render :new_batch, status: :unprocessable_entity
      return
    end

    invitations.each do |invitation|
      invitation.save!
      InvitationMailer.invitation_created(invitation).deliver_later
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
    @invitation.update! status: :accepted
    redirect_to @invitation, notice: "Invitation accepted."
  end

  def decline
    @invitation.update! status: :declined
    redirect_to @invitation, notice: "Invitation declined."
  end

  private
    # Only allow a list of trusted parameters through.
    def invitation_params
      ps = params.expect(invitation: [
        :collection_id, :message, :profile_email, :profile_first_name,
        :profile_last_name, :status, :profile_id
      ])
      if ps[:profile_id].blank?
        ps[:profile_id] = get_profile_id(
          ps[:profile_email], ps[:profile_first_name], ps[:profile_last_name]
        )
      end
      ps.except(:profile_email, :profile_first_name, :profile_last_name)
    end

    def get_profile_id(profile_email, profile_first_name, profile_last_name)
      user = User.find_or_create_by! email: profile_email
      profile = user.profiles.find_by email: profile_email
      if profile.nil?
        if !profile_email.blank? && !profile_first_name.blank? && !profile_last_name.blank?
          return user.profiles.create!(
            email: profile_email,
            first_name: profile_first_name,
            last_name: profile_last_name
          ).id
        else
          return nil
        end
      end
      profile.id
    end
end
