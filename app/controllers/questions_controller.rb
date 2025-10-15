class QuestionsController < ApplicationController # 質問テンプレートを扱うコントローラ
  before_action :set_visit, only: [ :select, :search, :create ] # どの受診予定（Visit）に紐づく質問なのかを明確にして、以降の処理で使えるようにする

  def index
    redirect_to visits_path, alert: "受診予定を選択してください"
  end

  # 質問選択画面の表示
  def select
    @departments = Department.all # DepartmentとQuestionCategoryをすべて取得
    @question_categories = QuestionCategory.all
    @questions = filter_questions # 絞り込みをかけた質問を格納する

    # 既に選択されている質問のIDを取得 チェック状態に使う
    @selected_question_ids = @visit.question_selections.pluck(:question_id)

    # フィルターの選択肢用配列 ユーザーに「全て」や特定の診療科・カテゴリを選択させる
    @department_options = [ [ "全て", "" ] ] + @departments.map { |dept| [ dept.name, dept.id ] }
    @category_options = [ [ "全て", "" ] ] + @question_categories.map { |cat| [ cat.category_name, cat.id ] }

    respond_to do |format| # ページ初期表示も、Ajax更新（例:絞り込み）にも使えるようにする
      format.html
      format.js
    end
  end

  # Ajaxによる質問の絞り込み検索
  def search
    @departments = Department.all
    @question_categories = QuestionCategory.all
    @questions = filter_questions
    @selected_question_ids = @visit.question_selections.pluck(:question_id) # visitに紐づくquestion_selectionsの一覧を取得。それらのレコードからquestion_idカラムだけを抜き出して配列として返す。
    # pluckは、ActiveRecordのメソッドで、データベースから特定のカラムの値だけを配列として取得
    respond_to do |format| # selectと同様のデータを取得し、Ajax対応のJSで返す。
      format.js
    end
  end

  def create
    # フォームから送られてきた「選択された質問IDの配列」を取り出す
    # もし何も選ばれていなかった場合（nil）でも安全に扱えるように Array() を使う
    question_ids = Array(params[:question_ids]).reject(&:blank?).map(&:to_i)

    # 1件も選ばれていなければ、元の画面に戻す
    if question_ids.empty?
      redirect_to questions_select_path(visit_id: @visit.id), alert: "質問を選択してください"
      return
    end

    # すでに登録されている質問IDを取り出す
    existing_question_ids = @visit.question_selections.pluck(:question_id)

    # 新しく追加すべき質問だけを抜き出す
    new_question_ids = question_ids - existing_question_ids

    # 登録できた件数を数えるための変数
    added_count = 0

    # 新しい質問IDごとに繰り返し登録する
    new_question_ids.each do |question_id|
      # 該当する質問を探す（見つからなければスキップ）
      question = Question.find_by(id: question_id)
      next if question.nil?

      # 受診予定（@visit）に紐づく質問選択を作成
      question_selection = @visit.question_selections.build(
        question_id: question_id,
        selected_at: Time.current,
        user_id: current_user.id,
        asked: false
      )

      # 保存に成功したらカウントを増やす
      if question_selection.save
        added_count += 1
      end
    end

    # 結果によってメッセージを出し分ける
    if added_count > 0
      redirect_to visit_question_selections_path(@visit),
                  notice: "#{added_count}件の質問が追加されました"
    else
      redirect_to questions_select_path(visit_id: @visit.id),
                  alert: "質問の追加に失敗しました"
    end
  end

  private

  def set_visit
    @visit = Visit.find_by(id: params[:visit_id]) # params[:visit_id]に該当するVisitレコードを1件探して@visitに代入する
    unless @visit # 見つからなかった場合
      redirect_to visits_path, alert: "受診予定を選択してください" # 訪問一覧ページ（visits_path）にリダイレクト
    end
  end

  def filter_questions
    questions = Question.includes(:department, :question_category) # 全質問に関連するdepartmentやquestion_categoryを一緒に取得してquestionsに代入

    if search_params[:department_id].present? # 全質問を関連するdepartmentやquestion_categoryを一緒に取得してquestionsに代入
      if search_params[:department_id] == "none" # "none"の場合は
        questions = questions.where(department_id: nil) # 診療科が設定されていない質問（nil）を抽出
      else
        questions = questions.where(department_id: search_params[:department_id]) # それ以外は一致する department_id を持つ質問を絞り込む
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
end
