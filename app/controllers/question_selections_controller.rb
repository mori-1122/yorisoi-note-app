class QuestionSelectionsController < ApplicationController
  before_action :authenticate_user! # Devise による認証（未ログインはリダイレクト）
  before_action :set_visit # visit_id パラメータから @visit を取得（全アクション共通）
  before_action :set_question_selection, only: [ :update ] # update 用。visit に紐づく質問選択を取得

  # page パラメータで画面（select or list）を切り替え
  def index
    @page = params[:page] || "select"

    if @page == "select"
      # 質問選択画面用の変数セット
      @departments = Department.all
      @question_categories = QuestionCategory.all
      @questions = build_questions_query
      @selected_question_ids = @visit.question_selections.pluck(:question_id)
      @user_questions = [] # ビューで未使用なら削除検討

      respond_to do |format|
        format.html { render "index" }
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
    else
      # 管理画面用の変数セット
      @question_selections = @visit.question_selections.includes(:question, :visit)
      @total_user_questions = @question_selections.count
      @user_questions = @question_selections
      @departments = Department.all
      @question_categories = QuestionCategory.all
      @master_questions = Question.all
      @upcoming_visits = current_user.visits.where("visit_date >= ?", Date.today)

      respond_to do |format|
        format.html { render "index" }
      end
    end
  end

  # 質問の登録
  def create # ユーザーが質問を選択して「登録」ボタンを押した時に呼ばれる
    question_ids = selection_params[:question_ids] || [] # パラメータからquestion_idsを取得。 nilの場合でも []をセットして処理を続行するため || []を使用。
    question_ids.reject!(&:blank?) # 空文字やnilが混じっている可能性があるため、排除し、IDのみ対象とする。reject!を使うことで元の配列を直接変更（破壊的）

    existing_question_ids = @visit.question_selections.pluck(:question_id) # visitに登録されている質問IDの一覧を取得。pluck(:question_id)により不要なActiveRecordオブジェクトを生成せず、DBから値のみ取得.
    new_question_ids = question_ids.map(&:to_i) - existing_question_ids # フォーム送信時の question_idsは "12"のような文字列で来るため、.map(&:to_i)整数に変換。差集合演算（-）により、既に登録済みのIDを除いた「新しく登録すべき質問ID」の配列が new_question_ids。

    new_question_ids.each do |question_id| # 新規登録対象の質問IDを1件ずつ処理。各question_id に対して、@visitに紐づくquestion_selection を作成。
      begin
        @visit.question_selections.create!(
          question_id: question_id, # question_id:対象の質問。
          user_id: current_user.id, # user_id: 登録したユーザー（ログイン中のユーザー）。
          selected_at: Time.current # selected_at:登録時刻を記録（管理・表示用に）。
          )
      rescue ActiveRecord::RecordInvalid # バリデーションエラーなどが発生した場合でも、処理全体を止めずに次のIDの処理に進む
      end
    end

    respond_to do |format|
      format.js
      format.html { redirect_to visit_question_selections_path(@visit, page: "list"), notice: "質問が追加されました" }
    end
  end

  # 質問の状態変更（toggle_asked ありならトグル）
  # 削除機能を追加
  def destroy
    @question_selection = @visit.question_selections.find(params[:id]) # この受診予定（@visit）に属する質問選択（question_selections）の中から、:id に一致するレコードを1件探して@question_selectionに代入する
    @question_selection.destroy!

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove(@question_selection)
      end
      format.html do
        redirect_to visit_question_selections_path(@visit, page: "list"),
                    notice: "質問を削除しました"
      end
    end
  end
  # 質問の状態変更
  def update
    if params[:toggle_asked].present? # リクエストに含まれるパラメータキーをtoggle_askedにした
      @question_selection.update!(asked: !@question_selection.asked)

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            @question_selection,
            partial: "question_selections/question_selection",
            locals: { selection: @question_selection }
          )
        end
        format.json { render json: { asked: @question_selection.asked } }
        format.html { redirect_to visit_question_selections_path(@visit, page: "list"), notice: "状態を更新しました" }
      end
    end
  end

  private

  def set_visit
    @visit = current_user.visits.find(params[:visit_id])
  end

  def set_question_selection
    @question_selection = @visit.question_selections.find(params[:id])
  end

  def selection_params
    params.require(:visit).permit(question_ids: [])
  end

  # def update_params
  #   params.require(:question_selection).permit(:asked, :memo)
  # end

  # 質問絞り込み（診療科・カテゴリ・キーワード対応）
  def build_questions_query
    questions = Question.all

    if params[:department_id].present?
      questions = params[:department_id] == "none" ?
        questions.where(department_id: nil) :
        questions.where(department_id: params[:department_id])
    end

    if params[:question_category_id].present?
      questions = params[:question_category_id] == "none" ?
        questions.where(question_category_id: nil) :
        questions.where(question_category_id: params[:question_category_id])
    end

    if params[:keyword].present?
      questions = questions.where("questions.content ILIKE ?", "%#{params[:keyword]}%")
    end

    questions
  end
end
