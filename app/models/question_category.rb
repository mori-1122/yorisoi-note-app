# == Schema Information
#
# Table name: question_categories
#
#  id            :integer          not null, primary key
#  category_name :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_question_categories_on_category_name  (category_name) UNIQUE
#

class QuestionCategory < ApplicationRecord
  has_many :questions

  validates :category_name, presence: true, uniqueness: true
end
