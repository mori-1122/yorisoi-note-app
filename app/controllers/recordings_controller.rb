class RecordingsController < ApplicationController # 録音に関するリクエストを処理するコントローラ
  before_action :authenticate_user! # ユーザーがログインしているか確認
  before_action :set_visit # コントローラの各アクションの前に、対応する Visit（診察記録）を取得して@visitにセット

  def new # 録音がまだ存在しなければ新しく作る。診療をする際に録音機能も作成する
    @visit = Visit.find(params[:visit_id]) # 受信先を表示したい
    @recording = @visit.recording || @visit.build_recording # 録音がまだ存在しなければ新しく作る。診療をする際に録音機能も作成する
  end

  def create
    @recording = @visit.build_recording(user: current_user, recorded_at: Time.current)
    @recording.audio_file.attach(params[:audio]) if params[:audio].present?

    if @recording.save && @recording.audio_file.attached?
      path = ActiveStorage::Blob.service.send(:path_for, @recording.audio_file.key)
      duration = `ffprobe -i "#{path}" -show_entries format=duration -v quiet -of csv=p=0`.to_f.round rescue 0

      blob = @recording.audio_file.blob
      blob.update(metadata: @recording.audio_file.blob.metadata.merge(custom_duration: duration))
      render json: { status: "OK", redirect_url: visit_recording_path(@visit) }
    else
      render json: { status: "error", errors: @recording.errors.full_messages }, status: :unprocessable_entity
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
