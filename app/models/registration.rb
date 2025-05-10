class Registration < ApplicationRecord
  belongs_to :registration_option
  has_many :payments, dependent: :destroy
  belongs_to :profile
  enum :status, { submitted: 0, accepted: 1, declined: 2 }
end
