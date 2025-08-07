class Recording < ApplicationRecord
  belongs_to :user # ユーザーに属する
  belongs_to :visit # 受診、診察に属する

  has_one_attached :audio_file # ActiveStorageを使用 ここの名前は任意で作成可能

  # validates :audio_file
  # gem導入を検討
end
