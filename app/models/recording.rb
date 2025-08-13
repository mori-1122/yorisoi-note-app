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
#  index_recordings_on_visit_id  (visit_id)
#

class Recording < ApplicationRecord
  belongs_to :user # ユーザーに属する
  belongs_to :visit # 受診、診察に属する

  has_one_attached :audio_file # ActiveStorageを使用 ここの名前は任意で作成可能

  # validates :audio_file
  # gem導入を検討
end
