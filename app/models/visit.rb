class Visit < ApplicationRecord
  belongs_to :user
  belongs_to :department
  has_one :memo
  has_many :documents, dependent: :destroy
  has_many :recordings, dependent: :destroy

  validates :visit_date, :hospital_name, :purpose, presence: true
end
