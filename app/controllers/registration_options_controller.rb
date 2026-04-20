class RegistrationOptionsController < ApplicationController
  layout "collections"
  load_and_authorize_resource :collection
  load_and_authorize_resource :registration_option, through: :collection, shallow: true
  before_action :set_collection

  def new
  end

  def show
    authorize! :manage, @registration_option.collection
    @registrations = @registration_option.collection.registrations.joins(:registration_option_choices)
      .where(registration_option_choices: { registration_option_id: @registration_option.id })
      .where("registration_option_choices.amount > ?", 0)
  end

  def edit
  end

  def create
    adjust_datetime_params
    respond_to do |format|
      if @registration_option.save
        format.html { redirect_to @registration_option, notice: "Option was successfully created." }
        format.json { render :show, status: :created, location: @registration_option }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @registration_option.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @registration_option.assign_attributes(registration_option_params)
    adjust_datetime_params
    respond_to do |format|
      if @registration_option.save
        format.html { redirect_to @registration_option, notice: "Option was successfully updated." }
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
        notice: "Option was successfully deleted." }
      format.json { head :no_content }
    end
  end
  private
    # Only allow a list of trusted parameters through.
    def registration_option_params
        params.expect(registration_option: [
          :name, :cost, :stock, :opens_on, :closes_on, :auto_accept, :allowed_domains, :info_prompt,
          :limit_one_per_registration
        ])
    end

    def adjust_datetime_params
      if @registration_option.opens_on.present? && @registration_option.opens_on_changed?
        @registration_option.opens_on = @registration_option.opens_on.asctime.in_time_zone(@registration_option.collection.inherited_time_zone)
      end
      if @registration_option.closes_on.present? && @registration_option.closes_on_changed?
        @registration_option.closes_on = @registration_option.closes_on.asctime.in_time_zone(@registration_option.collection.inherited_time_zone)
      end
    end

    def set_collection
      @collection = @registration_option.collection if @registration_option.present?
    end
end
