class Memo < ApplicationRecord
  belongs_to :user
  belongs_to :visit

  validates :file_path, presence: true
  validates :recorded_at, presence: true
end
