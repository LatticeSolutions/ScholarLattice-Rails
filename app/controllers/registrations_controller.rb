class RegistrationsController < ApplicationController
  load_and_authorize_resource :collection
  load_and_authorize_resource :registration, through: :collection, shallow: true, except: [ :create ]

  def index
    @registrations = @collection.subtree_registrations
    respond_to do |format|
      format.html
      if can? :manage, @collection
        format.csv { send_data @registrations.to_csv(@collection), filename: "registrations-#{@collection.short_title.underscore}-#{DateTime.now.strftime('%Q')}.csv" }
      end
    end
  end

  def show
  end

  def new
    unless @collection.registrations_in_stock?
      redirect_to @collection, alert: "No registrations remaining for this collection" and return
    end
    @registration.user = @current_user.present? ? @current_user : User.new
    @registration.ensure_choices_for_all_options
  end

  def edit
    @registration.ensure_choices_for_all_options
  end

  def create
    @registration = Registration.new(collection: @collection)
    changed_user_email = params[:user][:email] if params[:user].present?
    if (can? :manage, @collection) && changed_user_email.present?
      changed_user = User.find_by(email: changed_user_email)
      if changed_user.present?
        flash[:notice] = "Now creating registration for existing user with email #{changed_user_email}."
        @registration.user = changed_user
      else
        flash[:notice] = "Now creating registration for new user with email #{changed_user_email}."
        @registration.user = User.new(email: changed_user_email)
      end
      @registration.ensure_choices_for_all_options
      render :new and return
    end
    @registration.assign_attributes(registration_params)
    prune_registration_options
    only_admins_can_manage_other_users
    only_admins_update_status
    respond_to do |format|
      if @registration.save
        RegistrationMailer.registration_created(@registration).deliver_later
        format.html { redirect_to @registration, notice: "Registration was successfully created." }
        format.json { render :show, status: :created, location: @registration }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @registration.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    changed_user_email = params[:user][:email] if params[:user].present?
    if (can? :manage, @registration.collection) && changed_user_email.present?
      changed_user = User.find_by(email: changed_user_email)
      if changed_user.present?
        if @registration.update(user: changed_user)
          flash[:notice] = "Submitter email updated successfully."
          redirect_to edit_registration_path(@registration) and return
        else
          flash[:alert] = "Failed to update submitter email: #{@registration.errors.full_messages.join(', ')}"
          render :edit and return
        end
      else
        flash[:notice] = "Editing registration for new user with email #{changed_user_email}."
        @registration.user = User.new(email: changed_user_email)
        render :edit and return
      end
    end
    @registration.assign_attributes(registration_params)
    prune_registration_options
    only_admins_can_manage_other_users
    only_admins_update_status
    respond_to do |format|
      if @registration.save
        format.html { redirect_to @registration, notice: "Registration was successfully updated." }
        format.json { render :show, status: :ok, location: @registration }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @registration.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /submissions/1 or /submissions/1.json
  def destroy
    c = @registration.collection
    @registration.destroy!

    respond_to do |format|
      format.html { redirect_to collection_path(c), status: :see_other, notice: "Registration was successfully deleted." }
      format.json { head :no_content }
    end
  end


  private
    # Only allow a list of trusted parameters through.
    def registration_params
      params.expect(registration: [
        :status,
        :user_id,
        :registration_option_id_choice,
        user_attributes: [
          :id, :first_name, :last_name, :email, :affiliation,
          :position_type, :position, :affiliation_identifier
        ],
        registration_option_choices_attributes: [ [
          :id, :registration_option_id, :amount, :info
        ] ]
      ])
    end

    def prune_registration_options
      if @registration.collection.limit_one_registration_option?
        selected_option_id = params.dig(:registration_option_id_choice)
        @registration.registration_option_choices.reject { |c| c.registration_option_id == selected_option_id }.each do |choice|
          choice.amount = 0
          choice.info = nil
        end
      end
    end

    def only_admins_update_status
      if @current_user.ability.cannot?(:manage, @registration.collection)
        if @registration.new_record?
          if !@registration.submitted?
            @registration.errors.add(:status, "can only be set by collection admins")
          end
        elsif @registration.status_changed? && @registration.status_was.present?
          @registration.errors.add(:status, "can only be changed by collection admins")
        end
      end
    end

    def only_admins_can_manage_other_users
      if @registration.user != @current_user && cannot?(:manage, @registration.collection)
        @registration.errors.add(:user, "must be yourself")
      end
    end
end
