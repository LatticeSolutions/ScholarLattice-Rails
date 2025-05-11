class RegistrationPaymentsController < ApplicationController
  load_and_authorize_resource :registration
  load_resource :registration_payment, through: :registration, shallow: true

  # GET /registrations/new
  def new
  end

  # GET /registrations/1/edit
  def edit
  end

  # POST /registrations or /registrations.json
  def create
    respond_to do |format|
      if @registration_payment.save
        format.html { redirect_to @registration_payment.registration,
          notice: "Payment was successfully created." }
        format.json { render :show, status: :created, location: @registration_payment }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @registration_payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /registrations/1 or /registrations/1.json
  def update
    respond_to do |format|
      if @registration_payment.update(registration_payment_params)
        format.html { redirect_to @registration_payment.registration,
          notice: "Payment was successfully updated." }
        format.json { render :show, status: :ok, location: @registration_payment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @registration_payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /registrations/1 or /registrations/1.json
  def destroy
    c = @registration_payment.registration
    @registration_payment.destroy!

    respond_to do |format|
      format.html { redirect_to collection_registrations_path(c), status: :see_other,
        notice: "Payment was successfully destroyed." }
      format.json { head :no_content }
    end
  end
  private
    # Only allow a list of trusted parameters through.
    def registration_payment_params
        params.expect(registration_payment: [ :amount, :memo ])
    end
end
