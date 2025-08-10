# == Schema Information
#
# Table name: documents
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  visit_id   :integer          not null
#  image_path :string
#  doc_type   :string
#  taken_at   :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_documents_on_user_id   (user_id)
#  index_documents_on_visit_id  (visit_id)
#

class Document < ApplicationRecord
  belongs_to :user
  belongs_to :visit

  # image_path, doc_type, taken_at は任意なのでバリデーションなしとする
end
