class QuestionSelectionsController < ApplicationController
  before_action :set_visit, only: [ :index, :create ] # index、createアクションの前に対象のVisitを取得

  def index
    @visit = Visit.find(params[:visit_id]) #  Visitに紐づく質問を取得
    @question_selections = @visit.question_selections.includes(:question) # Visitに登録されている質問選択リストを効率よく取得するために、登録済みの質問(QuestionSelection)一覧を取得 includes(:question)により、各QuestionSelectionが持つquestionを事前にまとめて取得（N+1 問題防止）
  end

  def select # 質問を絞り込み表示する画面の処理
    @date = @visit.visit_date # ビューで表示するために@visitに設定された日付を取得
    @departments = Department.all # 全診療科、全カテゴリを取得して、フィルター表示用に渡す
    @question_categories = QuestionCategory.all

    # 全質問を取得し、ここからさらに絞り込む
    @questions = Question.all

    # パラメータにdepartment_idがあれば診療科ごとに絞り込む
    if params[:department_id].present?
      @questions = @questions.where(department_id: params[:department_id]) # present?を使い、パラメータが空やnilの場合はフィルターしないことで意図しない絞り込みを防ぐ
    end

    if params[:question_category_id].present? # 質問の内容で部分一致検索するため。
      @questions = @questions.where(question_category_id: params[:question_category_id])
    end

    if params[:keyword].present? # 質問の内容で部分一致検索するため
      @questions = @questions.where("questions.content ILIKE ?", "%#{params[:keyword]}%") # ILIKEを使うことでPostgreSQL環境での 大文字小文字を無視した検索 に対応。SQLインジェクション防止のため、パラメータ埋め込みはプレースホルダ (?) を使用。
    end

    # 既に選択済みの質問IDを取得（重複選択防止のため）
    @selected_question_ids = @visit.question_selections.pluck(:question_id)
  end


  def create # 質問選択画面から選ばれた質問を保存
    question_ids = selection_params[:question_ids] || [] # フォームから渡されたパラメータquestion_idsを取得。パラメータがない場合も考慮して空配列にfallbackすることでエラー防止。
    question_ids = question_ids.reject(&:blank?) # 空白を除外する
    existing_question_ids = @visit.question_selections.pluck(:question_id)
    new_question_ids = question_ids.map(&:to_i) - existing_question_ids

    new_question_ids.each do |question_id|
      @visit.question_selections.create(question_id: question_id, selected_at: Time.current)
    end

    redirect_to visit_question_selections_path(@visit), notice: "質問が追加されました"
  end

    private

  def set_visit
    @visit = Visit.find(params[:visit_id])
  end

  def selection_params
    params.permit(question_ids: [])
  end
end
