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

require "test_helper"

class QuestionCategoryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
