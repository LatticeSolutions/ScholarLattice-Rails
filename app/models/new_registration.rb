class NewRegistration < ApplicationRecord
  belongs_to :user
  belongs_to :collection
  validates :user_id, uniqueness: { scope: :collection_id }

  has_many :registration_option_choices, dependent: :destroy

  enum :status, { submitted: 0, accepted: 1, declined: 2 }

  accepts_nested_attributes_for :user, :registration_option_choices
end
