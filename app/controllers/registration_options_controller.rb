class RegistrationOptionsController < ApplicationController
  load_and_authorize_resource :collection
  load_resource :registration_option, through: :collection, shallow: true

  # GET /registrations/new
  def new
  end

  # GET /registrations/1/edit
  def edit
  end

  # POST /registrations or /registrations.json
  def create
    respond_to do |format|
      if @registration_option.save
        format.html { redirect_to collection_registrations_path(@registration_option.collection),
          notice: "Option was successfully created." }
        format.json { render :show, status: :created, location: @registration_option }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @registration_option.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /registrations/1 or /registrations/1.json
  def update
    respond_to do |format|
      if @registration_option.update(registration_option_params)
        format.html { redirect_to collection_registrations_path(@registration_option.collection),
          notice: "Option was successfully updated." }
        format.json { render :show, status: :ok, location: @registration_option }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @registration_option.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /registrations/1 or /registrations/1.json
  def destroy
    c = @registration_option.collection
    @registration_option.destroy!

    respond_to do |format|
      format.html { redirect_to collection_registrations_path(c), status: :see_other,
        notice: "Option was successfully destroyed." }
      format.json { head :no_content }
    end
  end
  private
    # Only allow a list of trusted parameters through.
    def registration_option_params
        params.expect(registration_option: [
          :name, :cost, :stock, :opens_on, :closes_on, :auto_accept
        ])
    end
end
