class Profile < ApplicationRecord
  belongs_to :user

  validates :birthday, presence: true
  validates :gender, presence: true
  validates :height, :weight, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  enum :gender, { male: 0, female: 1 }
  BLOOD_TYPES = [ "A型", "B型", "O型", "AB型", "不明" ].freeze
end
