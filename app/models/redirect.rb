class Redirect < ApplicationRecord
  validates :slug, presence: true, uniqueness: true
  validates :target_url, presence: true
end
