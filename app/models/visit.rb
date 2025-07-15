class Visit < ApplicationRecord
  belongs_to :user
  belongs_to :department
  has_many :documents, dependent: :destroy
  has_many :recordings, dependent: :destroy
  has_many :question_selections, dependent: :destroy

  #  Visitモデルが複数のquestion_selectionsを持つ
  has_many :question_selections, dependent: :destroy
  has_many :questions, through: :question_selections

  # 必須項目のバリデーション
  validates :visit_date, :hospital_name, :purpose, :appointed_at, presence: true

  # 重複登録のバリデーション
  validates :appointed_at, uniqueness: {
    scope: [ :user_id, :visit_date ],
    message: "は、すでに他の予定と重複して登録されています。"
  }

  validates :department_id, presence: true # #重複表示の修正

  validate :visit_date_cannot_be_in_the_past

  private

  def visit_date_cannot_be_in_the_past # #visit_dateが過去の日付かどうかをチェックする
    if visit_date.present? && appointed_at.present? && appointed_at < Date.current # #もしvisit_dateとappointed_atの両方が入力されていて、appointed_at（受診時間）が今日より前（つまり過去）であれば、
      errors.add(:visit_date, "は今日より後の日時を指定してください")
    end
  end
end
