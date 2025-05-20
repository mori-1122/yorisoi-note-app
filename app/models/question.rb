class Question < ApplicationRecord
  has_many :question_selections, dependent: :destroy

  validates :category, presence: true
  validates :content, presence: true
end
