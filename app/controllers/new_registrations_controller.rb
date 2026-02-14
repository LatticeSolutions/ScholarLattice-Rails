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


  private
    # Only allow a list of trusted parameters through.
    def registration_params
      # TODO..
      if can? :manage, @new_registration
        params.expect(registration: [ :registration_option_id, :status, :user_id, user_attributes: [ :id, :first_name, :last_name, :email, :affiliation, :position_type, :position, :affiliation_identifier ] ])
      else
        params.expect(registration: [ :registration_option_id, :user_id, user_attributes: [ :id, :first_name, :last_name, :email, :affiliation, :position_type, :position, :affiliation_identifier ] ])
      end
    end
end
