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
    if (cannot? :manage, @collection) && @collection.registrations.where(user: @current_user).any?
      redirect_to @collection.registrations.where(user: @current_user).first, alert: "You have already registered for this collection" and return
    end
    unless @collection.registrations_in_stock?
      redirect_to @collection, alert: "No registrations remaining for this collection" and return
    end
    if (can? :manage, @collection) && @collection.registrations.where(user: @current_user).any?
      @registration.user = User.new
    else
      @registration.user = @current_user
    end
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

  def upload
  end

  def import
    registrations_csv = params[:file]
    registration_csv_data = params[:registration_csv_data]
    @registration_param_symbols = [
      :submitter_email, :submitter_first_name, :submitter_last_name,
      :submitter_affiliation, :submitter_position
    ]
    if registrations_csv.present?
      require "csv"
      begin
        csv_table = CSV.read(registrations_csv, headers: true)
        @registration_data_array = csv_table.map(&:to_hash)
        @registration_data_headers = CSV.read(registrations_csv, headers: true).headers.reject(&:blank?)
        @registration_data_header_selections = [ [ "(none)", nil ] ] +
          @registration_data_headers.map { |h| [ "#{h} (#{@registration_data_array.first[h]&.truncate(40)})", h ] }
        render :import and return
      rescue => e
        flash[:alert] = "Error reading CSV file: #{e.message}"
        redirect_to collection_registrations_upload_path(@collection) and return
      end
    elsif registration_csv_data.present?
      users_to_save = []
      registrations_to_save = []
      user_cache = {}
      JSON.parse(registration_csv_data).each do |row|
        next if row[params[:submitter_email_header]].blank?
        email = row[params[:submitter_email_header]]
        u = user_cache[email] || User.find_or_initialize_by(email: email)
        next if @collection.registrations.where(user: u).any?
        if u.new_record? && !user_cache[email]
          u.assign_attributes(
            first_name: row[params[:submitter_first_name_header]] || "Unknown",
            last_name: row[params[:submitter_last_name_header]] || "Unknown",
            affiliation: row[params[:submitter_affiliation_header]] || "Unknown",
            position: row[params[:submitter_position_header]] || "Unknown",
            position_type: :other,
          )
          users_to_save << u
        end
        user_cache[email] = u
        registrations_to_save << @collection.registrations.build(
          user: u,
          status: params[:status] || :submitted,
          registration_option_choices_attributes: [
            {
              registration_option_id: params[:registration_option_id],
              amount: 1
            }
          ]
        )
      end
      invalid_users = users_to_save.reject(&:valid?)
      invalid_registrations = registrations_to_save.reject(&:valid?)
      if invalid_users.any? || invalid_registrations.any?
        error_messages = []
        error_messages += invalid_users.map { |u| "User #{u.email}: #{u.errors.full_messages.join(', ')}" }
        error_messages += invalid_registrations.map { |s| "registration: #{s.errors.full_messages.join(', ')}" }
        flash[:alert] = "Some records could not be imported: #{error_messages.join('; ')}"
        @registration_data_array = JSON.parse(registration_csv_data)
        @registration_data_headers = @registration_data_array.first.keys.reject(&:blank?)
        @registration_data_header_selections = [ [ "(none)", nil ] ] +
          @registration_data_headers.map { |h| [ "#{h} (#{@registration_data_array.first[h]&.truncate(40)})", h ] }
        render :import and return
      end
      users_to_save.each(&:save!)
      registrations_to_save.each(&:save!)
      flash[:alert] = "Registrations have been imported."
      redirect_to collection_registrations_path(@collection) and return
    else
      flash[:alert] = "Please select a CSV file to upload."
      redirect_to collection_registrations_upload_path(@collection) and return
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
