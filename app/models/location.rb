class Location < ApplicationRecord
  belongs_to :collection
  has_many :events
end
