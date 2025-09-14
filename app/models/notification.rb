class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :visit
  validates :title, :due_date, presence: true
end
