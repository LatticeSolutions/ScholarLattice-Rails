class Query < ApplicationRecord
  belongs_to :registration_option
  belongs_to :question
  validates :question_id, uniqueness: { scope: :registration_option_id, message: "can only be asked once" }
end
