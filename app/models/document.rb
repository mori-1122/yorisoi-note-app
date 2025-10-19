# Document モデルを残している理由
# 患者が病院から受け取る書類は多岐に渡り、紙ベースでは紛失のリスクもある。
# 種類を明確に管理できるようdoc_typeを保持することで、
# アプリ上での整理・参照を容易にするため。
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
