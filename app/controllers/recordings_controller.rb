class RecordingsController < ApplicationController # 録音に関するリクエストを処理するコントローラ
  before_action :authenticate_user! # ユーザーがログインしているか確認
  before_action :set_visit # コントローラの各アクションの前に、対応する Visit（診察記録）を取得して@visitにセット

  def new # 録音がまだ存在しなければ新しく作る。診療をする際に録音機能も作成する
    @recording = @visit.recording || @visit.build_recording
  end

  def create
    @recording = @visit.build_recording(user: current_user) # この診察（@visit）に紐づく録音（Recording）を新しく作り、その録音のuserをcurrent_userに設定する

    if params[:audio].present? # present?はオブジェクトが「存在していて」「空でない」ならtrueを返す
      @recording.audio_file.attach(params[:audio]) # リクエストパラメータに audio（音声ファイル）があれば、それを録音オブジェクトに添付し
    end

    if @recording.save # もしも保存できたら
      render json: { status: "OK" } # ステータスOKのJSONレスポンスを返す(jsを使っているから)
    else
      render json: { status: "error", errors: @recording.errors.full_messages }, status: :unprocessable_entity # 保存に失敗した場合はエラーメッセージを含むJSONを返し、ステータスコード422を添付
    end
  end

  def show
    @recording = @visit.recording # 診察に紐づく録音を取得して表示用に準備
  end

  def destroy
    @recording = @visit.recording # 診察に紐づく録音を取得して表示用に準備
    @recording.audio_file.purge # 録音に添付されている音声ファイルを削除
    @recording.destroy # 録音のデータベース上のレコードを削除

    redirect_to visit_path(@visit), notice: "録音を削除しました" # 診察の詳細ページへリダイレクトし、「録音を削除しました」という通知を表示します
  end

  private

  def set_visit
    @visit = Visit.find(params[:visit_id])
  end
end
