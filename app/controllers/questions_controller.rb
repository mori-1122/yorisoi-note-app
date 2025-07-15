class QuestionsController < ApplicationController # 質問テンプレートを扱うコントローラ
  def index # 受診予定にリダイレクト もしかしたら変更になるかも
    redirect_to visits_path, alert: "受診予定を選択してください"
  end

  def select # 「質問を選ぶ」画面を表示する
    @departments = Department.all # 質問を絞るための全ての診療科を取得してビューに出す
    @question_categories = QuestionCategory.all # 質問カテゴリーも取得
    @questions = Question.all # 全ての質問テンプレートを取得

    @questions = filter_questions

    # 診察記録から
    @visit = Visit.find(params[:visit_id]) if params[:visit_id].present?
  end

  def search
    @questions = filter_questions
    # Ajax検索用（将来的にTurboで実装予定）
    respond_to do |format|
      format.html { redirect_to select_questions_path(search_params) }
      format.json { render json: @questions.includes(:department, :question_category) }
      format.turbo_stream # 将来的にturboで実装
    end
  end

  private

  def filter_questions
    questions = Question.includes(:department, :question_category) # 最初は全ての質問データ (関連のdepartment, question_categoryも含めて取得)

    # 診療科での絞り込み
    if params[:department_id].present? && params[:department_id] != "全て" # 「もしparams[:department_id] が指定されていて、かつ値が"全て"ではない場合、その department_id に一致する質問だけを questions から絞り込む」
      questions = questions.where(department_id: params[:department_id])
    end

    if params[:question_category_id].present? && params[:question_category_id] != "全て"
      questions = questions.where(question_category_id: params[:question_category_id])
    end

    if params[:keyword].present?
      questions = questions.where("content ILIKE ?", "%#{params[:keyword]}%")
    end

    questions
  end

  def search_params
    params.permit(:department_id, :category_id, :keyword, :visit_id)
  end
end
