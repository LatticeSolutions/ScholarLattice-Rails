class Answer < ApplicationRecord
  belongs_to :question
  belongs_to :user
  validates :user_id, uniqueness: { scope: :question_id, message: "can only answer a question once" }
end
