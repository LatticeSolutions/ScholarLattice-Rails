class Question < ApplicationRecord
  belongs_to :collection

  def has_admin?(user)
    collection.present? && collection.has_admin?(user)
  end
end
