class Visit < ApplicationRecord
  belongs_to :user
  belongs_to :department
  has_one :memo
  has_many :documents, dependent: :destroy
  has_many :recordings, dependent: :destroy

  # 必須項目のバリデーション
  validates :visit_date, :hospital_name, :purpose, :appointed_at, presence: true

  # 予約時間は未来でなければならない
  validate :appointed_at_must_be_in_the_future

  private

  def appointed_at_must_be_in_the_future
    if appointed_at.present? && appointed_at < Time.current
      errors.add(:appointed_at, "は今日より後の日時を指定してください")
    end
  end
end
