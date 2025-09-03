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

class Visit < ApplicationRecord
  before_validation :combine_date_and_time
  belongs_to :user
  belongs_to :department
  has_many :documents, dependent: :destroy
  has_many :question_selections, dependent: :destroy
  has_one :recording, dependent: :destroy
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

  validate :appointed_at_cannot_be_in_the_past

  private

  # visit_date が「今日より後」かどうか
  def visit_date_cannot_be_in_the_past
    return if visit_date.blank?

    if visit_date <= Time.zone.today
      errors.add(:visit_date, "は、今日より後の日付を指定してください。")
    end
  end

  # appointed_at が「今より後」かどうか
  def appointed_at_cannot_be_in_the_past
    return if appointed_at.blank?

    if appointed_at <= Time.zone.now
      errors.add(:appointed_at, "は、現在以降の日時を指定してください。")
    end
  end
end
