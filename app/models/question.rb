class Question < ApplicationRecord
  belongs_to :collection

  has_many :queries
  has_many :registration_options, through: :queries

  def has_admin?(user)
    collection.present? && collection.has_admin?(user)
  end
end
