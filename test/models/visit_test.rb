# == Schema Information
#
# Table name: visits
#
#  id            :integer          not null, primary key
#  user_id       :integer          not null
#  visit_date    :date             not null
#  hospital_name :string           not null
#  purpose       :string           not null
#  has_recording :boolean
#  has_document  :boolean
#  department_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  memo          :text
#  appointed_at  :datetime         not null
#
# Indexes
#
#  index_visits_on_department_id   (department_id)
#  index_visits_on_user_date_time  (user_id,visit_date,appointed_at) UNIQUE
#  index_visits_on_user_id         (user_id)
#

require "test_helper"

class VisitTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
