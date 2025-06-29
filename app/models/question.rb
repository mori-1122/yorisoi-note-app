class Question < ApplicationRecord # #Questionモデルを定義
  belongs_to :department, optional: true # #department（診療科）に属することを示しつつ、optional: trueによって、診療科が未設定でも保存可能
  belongs_to :question_category, optional: true # 質問は question_category（カテゴリ）にも属す。任意であり、カテゴリがなくても保存可能とする。
  has_many :question_selections, dependent: :restrict_with_exception # #この質問が選択履歴として使われている場合、削除しようとすると例外を発生させて削除できない。

  validates :content, presence: true # #質問内容（content）は必須。空の場合は保存できない
  validates :content, uniqueness: {# #同じカテゴリ(question_category_id)と診療科(department_id)の組み合わせにおいて一意でなければならない
    scope: [ :question_category_id, :department_id ], # #カテゴリまたは診療科が異なれば、内容が重複しても登録可能
    message: "は、同じ診療科、カテゴリにすでにあります" }
  validate :department_or_category_must_be_present # #独自のバリデーション 診療科（department）もカテゴリ（question_category）も両方が空だと保存できない アプリケーションレベルのチェック

  private

  def department_or_category_must_be_present
    if department_id.blank? && question_category_id.blank? # #department_id と question_category_id の両方がnilであることをチェック
      errors.add(:base, "診療科に関する質問、またはカテゴリの質問のどちらかを選んでください") # #両方未設定の場合、モデル全体（:base）に対してバリデーションエラーを追加
    end
  end
end
