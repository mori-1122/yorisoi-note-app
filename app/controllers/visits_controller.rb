class VisitsController < ApplicationController
  before_action :set_visit, only: [ :edit, :update, :destroy ]

  def index # #通院予定の一覧ページを表示
    selected_date = params[:date].presence || Date.today # #URLにdate=2025-06-07みたいなパラメータがついていたらその日付、なければ今日の日付を使う 「選択された日付、または今日」をselected_dateに入れる
    @visit = Visit.new(visit_date: selected_date) # #フォーム用visitインスタンス 、日付フィールドが空じゃなく選択された日（または今日）になってる。
    @departments = Department.all # #プルダウンに診療科一覧を取得 フォームの「診療科」セレクトボックスに使われる
    @visits = current_user.visits
              .where("appointed_at >= ?", Time.current)
              .order(:appointed_at)
  end

  def new
    selected_date = params[:date].presence || Date.today
    @visit = Visit.new(visit_date: selected_date)
    @departments = Department.all # #プルダウンに診療科一覧を取得
    @visits = current_user.visits.where(visit_date: selected_date)
  end

  def create # ユーザーが新しい予定（Visit）を登録したときに呼び出される
    @visit = current_user.visits.build(visit_params) # 現在ログインしているユーザー（current_user）に紐づくVisitモデルの新しいインスタンスを作成
    if @visit.save
      # １、通知レコードを作る
      notification = current_user.notifications.create!(
        title: "【受診予定を新規登録しました】#{@visit.hospital_name}",
        description: "目的： #{@visit.purpose}",
        due_date: @visit.visit_date
      )

      # メールを送信する(非同期を使用)
      NotificationMailer.created(notification).deliver_later

      # 完了したらリダイレクトする
      redirect_to visits_path(date: @visit.visit_date), notice: "予定を保存しました"
    else
      @departments = Department.all # #フォームのセレクトボックスなどで使う「診療科（Department）」一覧を再度取得
      @visits = current_user.visits.where(visit_date: @visit.visit_date) # #その日付の通院予定一覧を再取得
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @visit = current_user.visits.find(params[:id])
    @departments = Department.all
  end

  def update
    @visit = current_user.visits.find(params[:id])
    if @visit.update(visit_params)
      redirect_to visits_path, notice: "予定を更新しました"
    else
      @departments = Department.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @visit = current_user.visits.find(params[:id])
    visit_date = @visit.visit_date
    @visit.destroy
    redirect_to visits_path(date: visit_date), notice: "予定を削除しました"
  end

  def by_date
    @visits = current_user.visits.where(visit_date: params[:date]) # #ログインユーザーの予定だけ取得
    render partial: "visits/schedule_list", locals: { visits: @visits } # #カレンダーの下などに表示する部分テンプレートを返す
  end

  private # 安全にユーザーからの入力を処理する

  def set_visit
    @visit = current_user.visits.find(params[:id])
  end

  def visit_params # #通院予定（Visit）登録時に受け付けるパラメータを制限（セキュリティ対策） 情報を抜き出す
    params.require(:visit).permit(
      :visit_date,
      :hospital_name,
      :appointed_at,
      :purpose,
      :has_recording,
      :has_document,
      :department_id,
      :memo
    )
  end
end
