class Collection < ApplicationRecord
  validates :title, presence: true
  validates :short_title, presence: true
  has_ancestry
  has_many :admins
  has_many :admin_users, through: :admins, source: :user
end
