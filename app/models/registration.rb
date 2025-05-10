class Registration < ApplicationRecord
  belongs_to :registration_option
  has_many :payments, dependent: :destroy
  belongs_to :profile
  has_one :collection, through: :registration_option
  enum :status, { submitted: 0, accepted: 1, declined: 2 }
end
