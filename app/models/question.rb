class Question < ApplicationRecord # #Questionモデルを定義
  belongs_to :department, optional: true # #一つの診療科に属す
  belongs_to :question_category, optional: true # この質問は1つのカテゴリ(question_category)に属する
  has_many :question_selections, dependent: :destroy # ユーザーの選択履歴と関連、質問削除時に選択も削除

  validates :content, presence: true # #質問内容（content）は必須。空の場合は保存できない
  validates :content, uniqueness: { message: "は、同じ診療科、カテゴリにすでにあります" }
  validate :department_or_category_must_be_present # #独自のバリデーション 診療科（department）もカテゴリ（question_category）も両方が空だと保存できない アプリケーションレベルのチェック

  private

  def department_or_category_must_be_present
    if department_id.blank? && question_category_id.blank? # #department_id と question_category_id の両方がnilであることをチェック
      errors.add(:base, "診療科に関する質問、またはカテゴリの質問のどちらかを選んでください") # #両方未設定の場合、モデル全体（:base）に対してバリデーションエラーを追加
    end
  end
end
