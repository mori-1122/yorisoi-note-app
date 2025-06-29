class QuestionSelection < ApplicationRecord
  belongs_to :user
  belongs_to :question
  belongs_to :visit

  validates :selected_at, presence: true

  # 同じ質問を同じvisitに対して重複登録しない
  validates :question_id, uniqueness: { scope: :visit_id, message: "は、この予定にすでに登録されています" }
end
