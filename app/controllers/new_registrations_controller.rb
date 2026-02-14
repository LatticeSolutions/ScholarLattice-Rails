class NewRegistrationsController < ApplicationController
  load_and_authorize_resource :collection
  load_and_authorize_resource :new_registration, through: :collection, shallow: true

  def index
    @new_registrations = @collection.subtree_new_registrations
    respond_to do |format|
      format.html
      if can? :manage, @collection
        format.csv { send_data @new_registrations.to_csv, filename: "registrations-#{@collection.short_title.underscore}-#{DateTime.now.strftime('%Q')}.csv" }
      end
    end
  end

  def show
  end

  def new
    unless @collection.new_registrations_in_stock?
      redirect_to @collection, alert: "No registrations remaining for this collection" and return
    end
    @new_registration.user = @current_user.present? ? @current_user : User.new
    @collection.registration_options.each do |option|
      @new_registration.registration_option_choices.build(registration_option: option, amount: 0)
    end
  end

  def edit
  end


  private
    # Only allow a list of trusted parameters through.
    def registration_params
      # TODO..
      if can? :manage, @new_registration
        params.expect(new_registration: [ :registration_option_id, :status, :user_id, user_attributes: [ :id, :first_name, :last_name, :email, :affiliation, :position_type, :position, :affiliation_identifier ], registration_option_choices_attributes: [ :id, :registration_option_id, :value ] ])
      else
        params.expect(new_registration: [ :registration_option_id, :user_id, user_attributes: [ :id, :first_name, :last_name, :email, :affiliation, :position_type, :position, :affiliation_identifier ] ])
      end
    end
end
