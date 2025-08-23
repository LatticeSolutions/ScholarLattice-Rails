class UserManagement < ApplicationRecord
  belongs_to :user
  belongs_to :manager, class_name: "User"
  validates :user_id, uniqueness: { scope: :manager_id }
  validate :user_and_manager_must_be_distinct

  private

  def user_and_manager_must_be_distinct
    if user_id == manager_id
      errors.add(:manager_id, "must be different from user_id")
    end
  end
end
