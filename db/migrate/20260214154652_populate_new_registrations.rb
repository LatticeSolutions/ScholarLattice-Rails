class PopulateNewRegistrations < ActiveRecord::Migration[8.0]
  def up
    # This will populate the new_registrations table based on existing registrations, and create corresponding registration option choices.
    Collection.find_each do |collection|
      User.where(id: collection.registrations.select(:user_id)).find_each do |user|
        if user.registrations.where(registration_option: collection.registration_options, status: :declined).any?
          status = :declined
        elsif user.registrations.where(registration_option: collection.registration_options, status: :submitted).any?
          status = :submitted
        else
          status = :accepted
        end
        new_registration = NewRegistration.create!(
          user_id: user.id,
          collection_id: collection.id,
          status: status
        )
        collection.registration_options.find_each do |registration_option|
          RegistrationOptionChoice.create!(
            new_registration: new_registration,
            registration_option: registration_option,
            amount: (user.registrations.find_by(registration_option: registration_option).present? ? 1 : 0)
          )
        end
      end
    end
  end
  def down
    # This will delete all new registrations and their associated registration option choices, so use with caution.
    RegistrationOptionChoice.delete_all
    NewRegistration.delete_all
  end
end
