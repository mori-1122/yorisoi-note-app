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

class Document < ApplicationRecord
  belongs_to :user
  belongs_to :visit
  has_one_attached :image

  enum :doc_type, {
    medical_record: "medical_record", # 診療記録
    prescription: "prescription", # 処方箋
    test_result: "test_result", # 検査結果
    insurance_card: "insurance_card", # 保険証
    referral_letter: "referral_letter", # 紹介状
    medical_certificate: "medical_certificate", # 診断書
    patient_card: "patient_card", # 診察券
    other: "other"
  }

  validates :image, attached: true, on: :create # 画像 (image) を 新規登録のときだけ必須にしたい 毎回画像を必須にすると不便と考えた
  validates :image, content_type: [ "image/png", "image/jpeg", "image/gif" ] # 画像のみとする
  validates :doc_type, presence: true, inclusion: { in: doc_types.keys }
end
