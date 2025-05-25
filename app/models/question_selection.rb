class QuestionSelection < ApplicationRecord
  belongs_to :user
  belongs_to :question

  validates :selected_at, presence: true
end
