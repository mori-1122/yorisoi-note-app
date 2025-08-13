# == Schema Information
#
# Table name: questions
#
#  id                   :integer          not null, primary key
#  content              :text             not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  department_id        :integer
#  question_category_id :integer
#
# Indexes
#
#  index_questions_on_content_add_category_and_department  (content,question_category_id,department_id) UNIQUE
#  index_questions_on_department_id                        (department_id)
#  index_questions_on_question_category_id                 (question_category_id)
#

require "test_helper"

class QuestionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
