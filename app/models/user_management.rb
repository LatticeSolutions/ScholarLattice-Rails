class UserManagement < ApplicationRecord
  belongs_to :user
  belongs_to :manager, class_name: "User"
  validates :user_id, uniqueness: { scope: :manager_id }
end
