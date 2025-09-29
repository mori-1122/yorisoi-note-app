class Department < ApplicationRecord
  has_many :visits

  validates :name, presence: true
end
