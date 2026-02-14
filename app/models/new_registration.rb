class NewRegistration < ApplicationRecord
  belongs_to :user
  belongs_to :collection
  validates :user_id, uniqueness: { scope: :collection_id }
  has_many :registration_option_choices, dependent: :destroy
end
