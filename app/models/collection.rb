class Collection < ApplicationRecord
  validates :title, presence: true
  validates :short_title, presence: true
  has_many :children, class_name: "Collection", foreign_key: "parent_id"
  belongs_to :parent, class_name: "Collection", optional: true
end
