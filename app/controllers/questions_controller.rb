class QuestionsController < ApplicationController # #質問テンプレートを扱うコントローラ
  def select # #「質問を選ぶ」画面を表示する
    @departments = Department.all # #質問を絞るための全ての診療科を取得してビューに出す
    @question_categories = QuestionCategory.all # #質問カテゴリーも取得
    @questions = Question.all # #全ての質問テンプレートを取得
    @visit = Visit.new
  end

  def search
  end
end
