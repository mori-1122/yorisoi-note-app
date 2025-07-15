class QuestionSelectionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_visit, only: [ :index, :create, :select, :toggle_answered ]

  def index
    @question_selections = @visit.question_selections.includes(:question) # Visitに登録されている質問選択リストを効率よく取得するために、登録済みの質問(QuestionSelection)一覧を取得 includes(:question)により、各QuestionSelectionが持つquestionを事前にまとめて取得（N+1 問題防止）
    @total_user_questions = @question_selections.count

    @user_questions = @question_selections

    @departments = Department.all
    @question_categories = QuestionCategory.all
    @master_questions = Question.all

    @upcoming_visits = current_user.visits.where("visit_date >= ?", Date.today)
  end

  def select
    @departments = Department.all
    @question_categories = QuestionCategory.all
    @questions = build_questions_query
    @selected_question_ids = @visit.question_selections.pluck(:question_id)

    respond_to do |format|
      format.html
      format.json do
        render json: {
          questions: @questions.as_json(only: [ :id, :content ], include: {
            department: { only: [ :id, :name ] },
            question_category: { only: [ :id, :category_name ] }
          }),
          selected_ids: @selected_question_ids
        }
      end
    end
  end

  def create # 質問選択画面から選ばれた質問を保存
    question_ids = selection_params[:question_ids] || [] # フォームから渡されたパラメータquestion_idsを取得。パラメータがない場合も考慮して空配列にfallbackすることでエラー防止。
    question_ids = question_ids.reject(&:blank?) # 空白を除外する
    existing_question_ids = @visit.question_selections.pluck(:question_id)
    new_question_ids = question_ids.map(&:to_i) - existing_question_ids

    new_question_ids.each do |question_id|
      @visit.question_selections.create(
        question_id: question_id,
        selected_at: Time.current,
        user_id: current_user.id,
        asked: false
      )
    end

    redirect_to visit_question_selections_path(@visit), notice: "質問が追加されました"
  end

  def build_questions_query
    questions = Question.all

    # 診療科を探す（department）
    if params[:department_id].present?
      if params[:department_id] == "none"
        questions = questions.where(department_id: nil)
      else
        questions = questions.where(department_id: params[:department_id])
      end
    end

    # カテゴリーを探す
    if params[:question_category_id].present?
      if params[:question_category_id] == "none"
        questions = questions.where(question_category_id: nil)
      else
        questions = questions.where(question_category_id: params[:question_category_id])
      end
    end

    # キーワードで探す
    if params[:keyword].present?
      questions = questions.where("questions.content ILIKE ? ", "%#{params[:keyword]}%")
    end

    questions
  end

  def toggle_answered
    selection = @visit.question_selections.find(params[:id])
    selection.update!(asked: !selection.asked)

    redirect_to visit_question_selections_path(@visit), notice: "質問の状態を変更しました"
  end

    private

  def set_visit
    @visit = current_user.visits.find(params[:visit_id])
  end

  def selection_params
    params.permit(question_ids: [])
  end
end
