class Collection < ApplicationRecord
  validates :title, presence: true
  validates :short_title, presence: true
end
