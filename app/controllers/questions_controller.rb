class QuestionsController < ApplicationController # 質問テンプレートを扱うコントローラ
  before_action :authenticate_user!
  before_action :set_visit, only: [ :select, :search, :create ]

  # 質問選択画面の表示
  def select
    @departments = Department.all
    @question_categories = QuestionCategory.all
    @questions = filter_questions

    # 既に選択されている質問のIDを取得
    @selected_question_ids = @visit.question_selections.pluck(:question_id)

    # フィルターの選択肢用配列
    @department_options = [ [ "全て", "" ] ] + @departments.map { |dept| [ dept.name, dept.id ] }
    @category_options = [ [ "全て", "" ] ] + @question_categories.map { |cat| [ cat.category_name, cat.id ] }

    respond_to do |format|
      format.html
      format.js
    end
  end

  # Ajaxによる質問の絞り込み検索
  def search
    @departments = Department.all
    @question_categories = QuestionCategory.all
    @questions = filter_questions
    @selected_question_ids = @visit.question_selections.pluck(:question_id)

    respond_to do |format|
      format.js
    end
  end

  # 質問選択の保存
  def create
    question_ids = params[:question_ids] || []
    question_ids = question_ids.reject(&:blank?).map(&:to_i)

    if question_ids.empty?
      redirect_to questions_select_path(visit_id: @visit.id), alert: "質問を選択してください"
      return
    end

    existing_question_ids = @visit.question_selections.pluck(:question_id)
    new_question_ids = question_ids - existing_question_ids

    success_count = 0
    errors = []

    new_question_ids.each do |question_id|
      question = Question.find_by(id: question_id)
      if question
        question_selection = @visit.question_selections.build(
          question_id: question_id,
          selected_at: Time.current,
          user_id: current_user.id,
          asked: false
        )

        if question_selection.save
          success_count += 1
        else
          errors << "質問ID #{question_id}: #{question_selection.errors.full_messages.join(', ')}"
        end
      else
        errors << "質問ID #{question_id} が見つかりません"
      end
    end

    if success_count > 0 && errors.empty?
      redirect_to visit_question_selections_path(@visit), notice: "#{success_count}件の質問が追加されました"
    elsif success_count > 0
      redirect_to visit_question_selections_path(@visit), notice: "#{success_count}件の質問が追加されました（一部エラーあり）"
    else
      error_message = errors.any? ? errors.join(", ") : "質問の追加に失敗しました"
      redirect_to questions_select_path(visit_id: @visit.id), alert: error_message
    end
  rescue => e
    redirect_to questions_select_path(visit_id: @visit.id), alert: "エラーが発生しました"
  end

  private

  def set_visit
    @visit = Visit.find_by(id: params[:visit_id])
    unless @visit
      redirect_to visits_path, alert: "受診予定を選択してください"
    end
  end

  def filter_questions
    questions = Question.includes(:department, :question_category)

    if search_params[:department_id].present?
      if search_params[:department_id] == "none"
        questions = questions.where(department_id: nil)
      else
        questions = questions.where(department_id: search_params[:department_id])
      end
    end

    if search_params[:question_category_id].present?
      if search_params[:question_category_id] == "none"
        questions = questions.where(question_category_id: nil)
      else
        questions = questions.where(question_category_id: search_params[:question_category_id])
      end
    end

    if search_params[:keyword].present?
      questions = questions.where("questions.content ILIKE ?", "%#{search_params[:keyword]}%")
    end

    questions
  end

  def search_params
    params.permit(:department_id, :question_category_id, :keyword, :visit_id)
  end

  def question_selection_params
    params.permit(question_ids: [])
  end

  def index
    redirect_to visits_path, alert: "受診予定を選択してください"
  end
end
