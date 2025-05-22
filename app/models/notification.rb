class Notification < ApplicationRecord
  belongs_to :user

  validates :title, :due_date, presence: true
end
