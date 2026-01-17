class RegistrationsController < ApplicationController
  load_and_authorize_resource :collection
  load_and_authorize_resource :registration, through: :collection, shallow: true, except: [ :index ]

  # GET /registrations or /registrations.json
  def index
    unless can? :manage, @collection
      redirect_to collection_path(@collection)
    end
    @registration_options = @collection.registration_options
    @registrations = Registration.where(registration_option: @registration_options)
    respond_to do |format|
      format.html
      if can? :manage, @collection
        format.csv { send_data @registrations.to_csv, filename: "registrations-#{@collection.short_title.underscore}-#{DateTime.now.strftime('%Q')}.csv" }
      end
    end
  end

  # GET /registrations/1 or /registrations/1.json
  def show
  end

  # GET /registrations/new
  def new
    if @current_user.present?
      @registration.user = @current_user
    else
      @registration.user = User.new
    end
  end

  # GET /registrations/1/edit
  def edit
  end

  # POST /registrations or /registrations.json
  def create
    # not logged in
    if @current_user.blank?
      # trying to log in
      if session_params.present?
        @session =  Passwordless::Session.find_by!(
          identifier: session_params[:identifier]
        )
        BCrypt::Password.create(session_params[:token])
        # success! sign in and continue creation
        if @session.authenticate(session_params[:token]) && @session.authenticatable.id == registration_params[:user_attributes][:id]
          sign_in(@session)
        # failure... return to the form
        else
          flash[:notice] = "Invalid token provided."
          render :new, status: :unprocessable_entity && return
        end
      # submitted but need to log in
      else
        @registration.user = User.new(registration_params[:user_attributes])
        @session = build_passwordless_session(@registration.user)
        # success! created new user and set up session
        if @registration.user.save && @session.save
          @registration.user_id = @registration.user.id
          RegistrationMailer.verify_email(@registration.user.email, @registration.collection.title, @session.token).deliver_later
          flash[:notice] = "Verify your email to complete your registration."
          render :new
          return
        # failure... send back
        else
          @session = nil
          flash[:notice] = "There was an error creating your account."
          render :new, status: :unprocessable_entity
          return
        end
      end
    end
    # logged in
    unless can? :manage, @collection or @registration.registration_option.in_stock?
      @registration.errors.add(:registration_option, "has no remaining stock available")
    end
    unless can? :manage, @collection or @registration.user.email == @current_user&.email
      @registration.errors.add(:registration, "must be for yourself")
    end
    if can? :manage, @collection and @registration.user.email != @current_user.email
      user_params = registration_params[:user_attributes].except(:id)
      @registration.user = User.find_or_create_by(email: user_params[:email])
      @registration.user.assign_attributes(user_params)
    end
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

  # PATCH/PUT /registrations/1 or /registrations/1.json
  def update
    @registration.user.assign_attributes(registration_params[:user_attributes]) if registration_params[:user_attributes].present?
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

  # DELETE /registrations/1 or /registrations/1.json
  def destroy
    c = @registration.collection
    @registration.destroy!

    respond_to do |format|
      format.html { redirect_to collection_path(c), status: :see_other, notice: "Registration was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def upload
  end

  def import
    registrations_csv = params[:file]
    require "csv"
    CSV.foreach(registrations_csv, headers: true) do |row|
      registration_data = row.to_hash
      u = User.find_by(email: registration_data["email"].downcase)
      if u.nil?
        u = User.create! registration_data.slice(
          "email",
          "first_name",
          "last_name",
          "affiliation",
          "position_type",
        )
      end
      registration_option = @collection.registration_options.find(
        registration_data["option_id"]
      )
      registration = registration_option.registrations.find_or_create_by!(
        user: u,
        status: registration_data["status"] || :submitted,
      )
      unless registration_data["amount"].blank?
        if registration_data["external_id"].blank? || !registration.registration_payments.exists?(external_id: registration_data["external_id"])
          registration.registration_payments.create!(
            amount: registration_data["amount"],
            memo: "#{registration_data["memo"]}\n\n(Imported from CSV. External ID: #{registration_data["external_id"]})",
            external_id: registration_data["external_id"],
          )
        end
      end
    end

    redirect_to collection_registrations_path(@collection), notice: "Registrations imported successfully."
  end

  private
    # Only allow a list of trusted parameters through.
    def registration_params
      if can? :manage, @registration
        params.expect(registration: [ :registration_option_id, :user_id, :status, user_attributes: [ :id, :first_name, :last_name, :email, :affiliation, :position_type, :position, :affiliation_identifier ] ])
      else
        params.expect(registration: [ :registration_option_id, :user_id, user_attributes: [ :id, :first_name, :last_name, :email, :affiliation, :position_type, :position, :affiliation_identifier ] ])
      end
    end
    def session_params
      return nil unless params[:session].present? && params[:session][:token].present?
      params.expect(session: [ :identifier, :token ])
    end
end
