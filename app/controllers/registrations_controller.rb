class RegistrationsController < ApplicationController
  load_and_authorize_resource :collection
  load_and_authorize_resource :registration, through: :collection, shallow: true

  # GET /registrations or /registrations.json
  def index
    authorize! :manage, @collection
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
      if @registration.save
        registrationMailer.registration_created(@registration).deliver_later
        format.html { redirect_to @registration, notice: "registration was successfully created." }
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
      if @registration.update(registration_params)
        registrationMailer.registration_updated(@registration).deliver_later
        format.html { redirect_to @registration, notice: "registration was successfully updated." }
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
      format.html { redirect_to collection_path(c), status: :see_other, notice: "registration was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Only allow a list of trusted parameters through.
    def registration_params
      if can? :manage, @registration
        params.expect(registration: [ :title, :abstract, :notes, :profile_id, :status, :collection_id ])
      else
        params.expect(registration: [ :title, :abstract, :notes, :profile_id ])
      end
    end
end
