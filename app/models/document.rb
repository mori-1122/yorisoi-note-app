class Document < ApplicationRecord
  belongs_to :user
  belongs_to :visit

  # image_path, doc_type, taken_at は NULL許容のためバリデーション不要
end
