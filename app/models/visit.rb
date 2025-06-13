class Visit < ApplicationRecord
  belongs_to :user
  belongs_to :department
  has_one :memo
  has_many :documents, dependent: :destroy
  has_many :recordings, dependent: :destroy

  # 必須項目のバリデーション
  validates :visit_date, :hospital_name, :purpose, :appointed_at, presence: true

  # 重複登録のバリデーション
  validates :hospital_name, uniqueness: {
    scope: [ :user_id, :visit_date ],
    message: "は、すでに他の予定と重複して登録されています。"
  }

  validates :department_id, presence: true # #重複表示の修正

  validate :visit_date_cannot_be_in_the_past

  private

  def visit_date_cannot_be_in_the_past
    if visit_date.present? && appointed_at < Date.current
      errors.add(:visit_date, "は今日より後の日時を指定してください")
    end
  end
end
