class Question < ApplicationRecord
  has_many :question_selections, dependent: :destroy

  validates :category, :content, presence: true
end
