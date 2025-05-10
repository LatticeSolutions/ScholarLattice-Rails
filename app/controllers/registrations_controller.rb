class RegistrationsController < ApplicationController
  load_and_authorize_resource :collection
  load_and_authorize_resource :registration, through: :collection, shallow: true, except: [ :index ]

  # GET /registrations or /registrations.json
  def index
    @registration_options = @collection.registration_options
    respond_to do |format|
      format.html
      format.csv { send_data @registrations.to_csv, filename: "registrations-#{@collection.short_title.underscore}-#{DateTime.now.strftime('%Q')}.csv" }
    end
  end

  # GET /registrations/1 or /registrations/1.json
  def show
  end

  # GET /registrations/new
  def new
  end

  # GET /registrations/1/edit
  def edit
  end

  # POST /registrations or /registrations.json
  def create
    respond_to do |format|
      if @registration.registration_option.collection_id != params[:collection_id]
        @registration.errors.add(:registration_option, "does not match this collection")
      end
      if @registration.save
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
    respond_to do |format|
      if @registration.registration_option.collection_id !=
          Registration.new(registration_params).registration_option.collection_id
        @registration.errors.add(:registration_option, "does not match this collection")
      end
      if @registration.update(registration_params)
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

  private
    # Only allow a list of trusted parameters through.
    def registration_params
      if can? :manage, @registration
        params.expect(registration: [ :registration_option_id, :profile_id, :status ])
      else
        params.expect(registration: [ :registration_option_id, :profile_id ])
      end
    end
end
