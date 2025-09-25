class Visit < ApplicationRecord
  before_validation :combine_date_and_time
  belongs_to :user
  belongs_to :department
  has_many :documents, dependent: :destroy
  has_many :question_selections, dependent: :destroy
  has_one :recording, dependent: :destroy
  has_many :questions, through: :question_selections
  has_many :notifications, dependent: :destroy # Visitごとに「即時通知」「前日リマインダー通知」と複数記録するため

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

  # 通知に関連する
  def create_notifications
    # 即時通知
    immediate = notifications.create(
      user: user,
      title: "【受診予定を新規登録しました】#{hospital_name}",
      description: "日付： #{visit_date.strftime("%-m月%-d日")}\n時間：#{appointed_at.strftime("%H:%M")}\n目的：#{purpose}",
      due_date: Date.current, # 今日
      is_sent: false
    )
    # 作成した即時通知をジョブキューに追加する
    ImmediateNotificationJob.perform_later(immediate.id)


    # 前日通知
    reminder = notifications.create(
      user: user,
      title: "【受診に関するリマインド】#{hospital_name}",
      description: "明日は受診日です。\n日付： #{visit_date.strftime("%-m月%-d日")}\n時間：#{appointed_at.strftime("%H:%M")}\n目的：#{purpose}",
      due_date: visit_date - 1.day,
      is_sent: false
    )
  end

  private

  def combine_date_and_time
    return if visit_date.blank? || appointed_at.blank?

    time_str = appointed_at.is_a?(String) ? appointed_at : appointed_at.strftime("%H:%M")
    self.appointed_at = Time.zone.parse("#{visit_date} #{time_str}")
  end
  # visit_date が「今日より後」かどうか
  def visit_date_cannot_be_in_the_past
    return if visit_date.blank?

    if visit_date < Time.zone.today
      errors.add(:visit_date, "は、今日以降の日付を指定してください。")
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
