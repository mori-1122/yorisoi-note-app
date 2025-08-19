# == Schema Information
#
# Table name: recordings
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  visit_id    :integer          not null
#  recorded_at :datetime         not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_recordings_on_user_id   (user_id)
#  index_recordings_on_visit_id  (visit_id) UNIQUE
#

require "test_helper"

class RecordingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
