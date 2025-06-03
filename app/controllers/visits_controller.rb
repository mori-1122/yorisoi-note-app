class VisitsController < ApplicationController
  before_action :authenticate_user!
  def index
    # 表示
  end

  def create # ユーザーが新しい予定（Visit）を登録したときに呼び出される
    @visit = current_user.visits.build(visit_params) # 現在ログインしているユーザー（current_user）に紐づくVisitモデルの新しいインスタンスを作成
    if @visit.save # 作成した予定をデータベースに保存
      render json: { status: "予定が作成されました", visit: @visit } # 予定の作成に成功したら、status: 'created' と作成された予定（@visit）の情報をJSON形式で返す
    else
      render json: { status: "作成し直して下さい", errors: @visit.errors.full_messages }, status: :unprocessable_entity # 保存に失敗した場合、status:'error'とエラーメッセージ
    end
  end

  def by_date
    @visits = current_user.visits.where(visit_date: params[:date])
    render partial: "visits/schedule_list", locals: { visits: @visits }
  end

  private # 安全にユーザーからの入力を処理する

  def visit_params
    params.require(:visit).permit(
      :visit_date,
      :hospital_name,
      :purpose,
      :has_recording,
      :has_document,
      :memo_id,
      :department_id
    )
  end
end
