class QuestionsController < ApplicationController # 質問テンプレートを扱うコントローラ
  before_action :authenticate_user! # 未ログインのユーザーがアクセスしようとしたらログイン画面へリダイレクト
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

    respond_to do |format| # ページ初期表示も、Ajax更新（例: 絞り込み）にも使えるようにする
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

  # 質問選択の保存
  def create
    question_ids = params[:question_ids] || [] # フォームやURLから渡された「選択された質問IDの配列」を受け取る。params[:question_ids]が存在しない場合は、空の配列[]を使う。
    question_ids = question_ids.reject(&:blank?).map(&:to_i) # 空文字列("")、nil、スペースなどの“空っぽ”な値を除外する。to_iで各値をStringからIntegerに変換

    if question_ids.empty? # もしも、質問のIDがなかったら
      redirect_to questions_select_path(visit_id: @visit.id), alert: "質問を選択してください" # 質問選択画面に戻して、エラーメッセージを表示する
      return
    end

    existing_question_ids = @visit.question_selections.pluck(:question_id) # 重複登録を防ぐためと、登録済みの質問を除外するため。@visitに紐づくすべてのquestion_selectionsからquestion_idのみを抽出して、すでに（DBに）存在している質問IDたちに格納する。
    new_question_ids = question_ids - existing_question_ids # 新たに選択されたけど、まだ登録されていない質問IDだけを抜き出す

    success_count = 0 # 登録した質問を数える。
    errors = [] # 登録に失敗した時の文字を入れる。配列。

    new_question_ids.each do |question_id| # 新しい質問IDを1つずつ取り出して処理する。ブロック変数question_idを使って登録処理をする。
      question = Question.find_by(id: question_id) # モデルでuniqueness複合ユニーク制約を作っているので、組み合わせで1件だけに絞るのでfind_by
      if question # もしも質問があったら 質問を「受診予定に対して登録する」ための処理をする
        question_selection = @visit.question_selections.build( # @visit（受診予定）に紐づくquestion_selections（質問選択）の新しいインスタンスを作る
          question_id: question_id, # 対象の質問IDを指定する
          selected_at: Time.current, # 今この瞬間の日時を「選択された時刻」として記録
          user_id: current_user.id, # ログインした人
          asked: false # 質問できたかどうかはまだ判断しない
        )

        if question_selection.save # もしも、選択した質問を保存したら
          success_count += 1 # 成功した件数をユーザーに通知するためにカウントする。保存成功で、１件増やす。
        else
          errors << "質問ID #{question_id}: #{question_selection.errors.full_messages.join(', ')}" # 保存に失敗したら、その理由を文字列にする、joinで１行にまとめる。
        end
      else
        errors << "質問ID #{question_id} が見つかりません"
      end
    end

    if success_count > 0 && errors.empty? # 登録に成功した質問が１個以上あって、エラーもなかったら
      redirect_to visit_question_selections_path(@visit), notice: "#{success_count}件の質問が追加されました"
    elsif success_count > 0 # 部分的に質問は登録できたけど、エラーもあった
      redirect_to visit_question_selections_path(@visit), notice: "#{success_count}件の質問が追加されました（一部エラーあり）"
    else
      error_message = errors.any? ? errors.join(", ") : "質問の追加に失敗しました" # 三項演算子 　errorsに何か入っていればそれをjoin(", ")で連結して表示用にまとめる
      redirect_to questions_select_path(visit_id: @visit.id), alert: error_message # 質問選択画面に戻す
    end
  rescue => e # 例外処理　エラーが起きたとき
    redirect_to questions_select_path(visit_id: @visit.id), alert: "エラーが発生しました"
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
