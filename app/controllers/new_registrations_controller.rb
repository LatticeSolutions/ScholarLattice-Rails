class NewRegistrationsController < ApplicationController
  load_and_authorize_resource :collection
  load_and_authorize_resource :new_registration, through: :collection, shallow: true

  def index
    @new_registrations = @collection.subtree_new_registrations
    respond_to do |format|
      format.html
      if can? :manage, @collection
        format.csv { send_data @new_registrations.to_csv(@collection), filename: "registrations-#{@collection.short_title.underscore}-#{DateTime.now.strftime('%Q')}.csv" }
      end
    end
  end

  def show
  end

  def new
    unless @collection.registrations_in_stock?
      redirect_to @collection, alert: "No registrations remaining for this collection" and return
    end
    @new_registration.user = @current_user.present? ? @current_user : User.new
    @new_registration.ensure_choices_for_all_options
  end

  def edit
    @new_registration.ensure_choices_for_all_options
  end

  def create
    prune_registration_options
    only_admins_update_status
    respond_to do |format|
      if @new_registration.save
        NewRegistrationMailer.new_registration_created(@new_registration).deliver_later
        format.html { redirect_to @new_registration, notice: "New registration was successfully created." }
        format.json { render :show, status: :created, location: @new_registration }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @new_registration.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @new_registration.assign_attributes(new_registration_params)
    prune_registration_options
    only_admins_update_status
    respond_to do |format|
      if @new_registration.save
        format.html { redirect_to @new_registration, notice: "New registration was successfully updated." }
        format.json { render :show, status: :ok, location: @new_registration }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @new_registration.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /submissions/1 or /submissions/1.json
  def destroy
    c = @new_registration.collection
    @new_registration.destroy!

    respond_to do |format|
      format.html { redirect_to collection_path(c), status: :see_other, notice: "Registration was successfully deleted." }
      format.json { head :no_content }
    end
  end


  private
    # Only allow a list of trusted parameters through.
    def new_registration_params
      params.expect(new_registration: [
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
      if @new_registration.collection.limit_one_registration_option?
        selected_option_id = params.dig(:registration_option_id_choice)
        @new_registration.registration_option_choices.reject { |c| c.registration_option_id == selected_option_id }.each do |choice|
          choice.amount = 0
          choice.info = nil
        end
      end
    end

    def only_admins_update_status
      if @current_user.ability.cannot?(:manage, @new_registration.collection)
        if @new_registration.new_record?
          if !@new_registration.submitted?
            @new_registration.errors.add(:status, "can only be set by collection admins")
          end
        elsif @new_registration.status_changed? && @new_registration.status_was.present?
          @new_registration.errors.add(:status, "can only be changed by collection admins")
        end
      end
    end
end
