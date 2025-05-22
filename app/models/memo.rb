class Memo < ApplicationRecord
  belongs_to :user
  belongs_to :visit

  validates :content, presence: true
end
