class RegistrationPayment < ApplicationRecord
  belongs_to :registration
  def collection
    registration.collection
  end
end
