class RecordingsController < ApplicationController # 録音に関するリクエストを処理するコントローラ
  before_action :authenticate_user! # ユーザーがログインしているか確認
  before_action :set_visit # コントローラの各アクションの前に、対応する Visit（診察記録）を取得して@visitにセット

  def new # 録音がまだ存在しなければ新しく作る。診療をする際に録音機能も作成する
    @recording = @visit.recording || @visit.build_recording # 録音がまだ存在しなければ新しく作る。診療をする際に録音機能も作成する
  end

  def create
    @recording = @visit.build_recording(user: current_user, recorded_at: Time.current, audio_file: params[:audio]) # 「誰の録音か」を明確に。 recorded_at:Time.currentで録音日時を保存する→後で検索・表示に必要。 audio_file:params[:audio]で送信された音声ファイルを直接添付する。
    path = ActiveStorage::Blob.service.send(:path_for, @recording.audio_file.key)
    if @recording.save && @recording.audio_file.attached? # 録音ファイルがきちんと保存されているか
      # Ruby標準ライブラリのOpen3.capture3は、コマンドの標準出力・標準エラー・終了ステータスをまとめて取得できる。

      # ffprobe で音声ファイルの再生時間を取得
      stdout, stderr, status = Open3.capture3(
        "ffprobe",
        "-i", path,
        "-show_entries", "format=duration",
        "-v", "quiet",
        "-of", "csv=p=0"
      )
      duration = stdout.to_f.round rescue 0 # 数値化。失敗時は0
      # stdoutOpen3.capture3 の戻り値のひとつ。ffprobe の標準出力が入る。
      # to_f標準出力は文字列なので、to_f で 浮動小数点数（Float）
      # ffprobe の実行が失敗した場合や、出力が得られなかった場合に備えたフェイルセーフ。例外が起きたらduration = 0にして処理を継続する

      blob = @recording.audio_file.blob # active storageはアップロードされたファイルをBlobとして扱う。blobオブジェクトを取得することで、このファイルに対してメタデータの追加や操作が可能に。
      blob.update(metadata: @recording.audio_file.blob.metadata.merge(custom_duration: duration))# ビューで再生時間を表示するためにActiveStorageのmetadataにdurationを独自項目 (custom_duration)として追加保存。既存のmetadataに .mergeで追加しているので、他のメタ情報（content_type, sizeなど）は保持されたまま。
      render json: { status: "OK", redirect_url: visit_recording_path(@visit) } # フロントエンドに「保存成功」をJSONで返す。
    else
      render json: { status: "error", errors: @recording.errors.full_messages }, status: :unprocessable_entity # エラーメッセージをJSONで返却する。
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
