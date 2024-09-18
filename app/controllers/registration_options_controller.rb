class RegistrationOptionsController < ApplicationController
  before_action :set_registration_option, only: %i[ show edit update destroy ]

  # GET /registration_options or /registration_options.json
  def index
    @registration_options = RegistrationOption.all
  end

  # GET /registration_options/1 or /registration_options/1.json
  def show
  end

  # GET /registration_options/new
  def new
    @registration_option = RegistrationOption.new
  end

  # GET /registration_options/1/edit
  def edit
  end

  # POST /registration_options or /registration_options.json
  def create
    @registration_option = RegistrationOption.new(registration_option_params)

    respond_to do |format|
      if @registration_option.save
        format.html { redirect_to registration_option_url(@registration_option), notice: "Registration option was successfully created." }
        format.json { render :show, status: :created, location: @registration_option }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @registration_option.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /registration_options/1 or /registration_options/1.json
  def update
    respond_to do |format|
      if @registration_option.update(registration_option_params)
        format.html { redirect_to registration_option_url(@registration_option), notice: "Registration option was successfully updated." }
        format.json { render :show, status: :ok, location: @registration_option }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @registration_option.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /registration_options/1 or /registration_options/1.json
  def destroy
    @registration_option.destroy!

    respond_to do |format|
      format.html { redirect_to registration_options_url, notice: "Registration option was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_registration_option
      @registration_option = RegistrationOption.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def registration_option_params
      params.require(:registration_option).permit(:collection_id, :title, :description, :opens_at, :closes_at)
    end
end
