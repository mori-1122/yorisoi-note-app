class User < ApplicationRecord
  has_many :visits, dependent: :destroy
  has_many :memos, dependent: :destroy
  has_many :recordings, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :question_selections, dependent: :destroy
  has_many :notifications, dependent: :destroy

  validates :name,  presence: true, length: { maximum: 20 }
  validates :email, presence: true, length: { maximum: 300 }, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }
end
