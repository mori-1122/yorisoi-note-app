class RecordingsController < ApplicationController # 録音に関するリクエストを処理するコントローラ
  before_action :authenticate_user! # ユーザーがログインしているか確認
  before_action :set_visit # コントローラの各アクションの前に、対応する Visit（診察記録）を取得して@visitにセット

  def new # 録音がまだ存在しなければ新しく作る。診療をする際に録音機能も作成する
    @recording = @visit.recording || @visit.build_recording # 録音がまだ存在しなければ新しく作る。診療をする際に録音機能も作成する
  end

  def create
    @recording = @visit.build_recording(
      user: current_user,
      recorded_at: Time.current,
      audio_file: params[:audio]
    )

    if @recording.save && @recording.audio_file.attached?
      duration = fetch_audio_duration(@recording.audio_file)
      @recording.audio_file.blob.update(
        metadata: @recording.audio_file.blob.metadata.merge(custom_duration: duration)
      )
      render json: { status: "OK", redirect_url: visit_recording_path(@visit) }
    else
      render json: { status: "error", errors: @recording.errors.full_messages },
             status: :unprocessable_entity
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

  def fetch_audio_duration(file)
    path = File.expand_path(ActiveStorage::Blob.service.send(:path_for, file.key))
    stdout, stderr, status = Open3.capture3(
      "ffprobe", "-i", path, "-show_entries", "format=duration",
      "-v", "quiet", "-of", "csv=p=0"
    )
    status.success? ? stdout.to_f.round : 0
  end
end
