class QuestionCategory < ApplicationRecord
  has_many :questions

  validates :category_name, presence: true, uniqueness: true
end
