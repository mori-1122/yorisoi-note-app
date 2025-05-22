class Document < ApplicationRecord
  belongs_to :user
  belongs_to :visit

  # image_path, doc_type, taken_at は任意なのでバリデーションなしとする
end
