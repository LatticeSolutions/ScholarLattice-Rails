class RegistrationOptionChoice < ApplicationRecord
  belongs_to :new_registration
  belongs_to :registration_option
  validates :new_registration_id, uniqueness: { scope: :registration_option_id }
  validates :amount, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
