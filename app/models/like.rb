class Like < ApplicationRecord
  belongs_to :user
  belongs_to :collection
  validates_uniqueness_of :user, scope: :collection
end
