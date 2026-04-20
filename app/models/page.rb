class Page < ApplicationRecord
  belongs_to :collection
  before_validation :enforce_single_homepage
  enum :visibility, { private: 0, unlisted: 1, public: 2 }, suffix: true

  default_scope { order(:order, :title) }

  def has_admin?(user)
    collection.present? && collection.has_admin?(user)
  end
end
