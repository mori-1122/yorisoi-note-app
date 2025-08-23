# == Schema Information
#
# Table name: documents
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  visit_id   :integer          not null
#  doc_type   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_documents_on_user_id   (user_id)
#  index_documents_on_visit_id  (visit_id)
#

require "test_helper"

class DocumentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
