class Visit < ApplicationRecord
  belongs_to :user
  has_one :memo, dependent: :destroy
  has_many :recordings, dependent: :destroy
  has_many :documents, dependent: :destroy

  validates :visit_date, presence: true
  validates :hospital_name, presence: true
  validates :purpose, presence: true
end
