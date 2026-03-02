class RegistrationOptionChoice < ApplicationRecord
  belongs_to :registration
  belongs_to :registration_option
  validates :registration_id, uniqueness: { scope: :registration_option_id }
  validates :amount, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  default_scope { joins(:registration_option).order("registration_options.name ASC") }

  def has_cost?
    registration_option.cost.present?
  end

  def total_cost
    return nil unless has_cost?
    amount * registration_option.cost
  end
end
