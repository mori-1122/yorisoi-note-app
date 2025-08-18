# == Schema Information
#
# Table name: recordings
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  visit_id    :integer          not null
#  recorded_at :datetime         not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_recordings_on_user_id   (user_id)
#  index_recordings_on_visit_id  (visit_id)
#

class Recording < ApplicationRecord # アクティブレコードを定義
  belongs_to :user # ユーザーに属する 外部キー
  belongs_to :visit # 受診、診察に属する 外部キー

  has_one_attached :audio_file # ActiveStorageを使用 ここの名前は任意で作成可能。ActiveStorageを使って音声ファイルを1つ添付できるようにしている。添付の名前はaudio_file。
  has_one_attached :converted_audio # mp３に変換 #実体はactive_storage_blobsテーブルに記録される

  validates :audio_file, # audio_fileが必ず付いていることをバリデーション active_storage_validations gemの仕様
            attached: true, # audio_fileが必ず添付されている
            content_type: [ "audio/webm" ], # 添付されたファイルのMIMEタイプが audio/webm
            size: { less_than: 2.megabytes } # ファイルサイズは２mb未満

  after_commit :add_duration_and_convert, on: :create # コールバック　レコードがDBに保存されてトランザクションが確定した後に呼ばれる。コールバックのタイミングを「新規作成時」に限定する。
  # 録音（Recording）が新規保存された後（commit後）に、ffmpegでdurationを取得し、WebMをMP3に変換してconverted_audioに添付する」という処理を毎回自動的に行うため、コールバックを利用している。

  private

  def add_duration_and_convert
    return unless audio_file.attached? # audio_fileが添付されていなければ何もせず終了 ファイルが無い状態で処理しても意味がないため

    path       = ActiveStorage::Blob.service.send(:path_for, audio_file.key) # ActiveStorage内に保存されている path_forを使うとファイルシステム上の実ファイルパスが取れる
    fixed_path = "#{path}.fixed.webm" # コピー後のWebMファイル（メタデータ修正用）。
    mp3_path   = "#{path}.mp3" # 変換後MP3ファイル。

    begin
      # # 録音時間を埋め直す Chrome の MediaRecorder が出力する WebM は duration メタ情報が欠ける場合がある
      # system("ffmpeg -i #{Shellwords.escape(path)} -c copy #{Shellwords.escape(fixed_path)} -y -loglevel quiet") # -c copyはデータをある形式に変換する処理のエンコードをせずにストリーム(中に入ってる個々のデータの流れ)をコピーし、ヘッダーを書き直す

      # duration = `ffprobe -i #{Shellwords.escape(fixed_path)} -show_entries format=duration -v quiet -of csv=p=0`.to_f # ffprobe で WebM ファイルの長さを秒数で取得。RubyでFloatに変換。ActiveStorageのblob.metadataにdurationを追加してDBに保存。
      # audio_file.blob.update(metadata: audio_file.blob.metadata.merge(duration: duration)) # 録音時間が Rails 内で参照可能になる。

      # # WebM → MP3 に変換 スマホでも聴けるようにするため
      # system("ffmpeg -i #{Shellwords.escape(fixed_path)} -ar 44100 -ac 2 -b:a 192k #{Shellwords.escape(mp3_path)} -y -loglevel quiet")

      # if File.exist?(mp3_path) # 変換したMP3ファイルが存在すれば、ActiveStorage の converted_audio に添付する。
      #   converted_audio.attach(
      #     io: File.open(mp3_path),
      #     filename: "recording.mp3",
      #     content_type: "audio/mpeg" # MIMEタイプを明示し、ダウンロードやストリーミングに対応。
      #   )
      # end

      # WebMのdurationを補完する（ffmpegでヘッダ書き換え）
      _stdout, stderr, status = Open3.capture3(
        "ffmpeg", "-i", path, "-c", "copy", fixed_path,
        "-y", "-loglevel", "quiet"
      )
      Rails.logger.error "ffmpeg (fix metadata) failed: #{stderr}" unless status.success?

      # ffprobe で録音時間を取得
      stdout, stderr, status = Open3.capture3(
        "ffprobe", "-i", fixed_path,
        "-show_entries", "format=duration",
        "-v", "quiet", "-of", "csv=p=0"
      )
      if status.success?
        duration = stdout.to_f
        audio_file.blob.update(metadata: audio_file.blob.metadata.merge(duration: duration))
      else
        Rails.logger.error "ffprobe failed: #{stderr}"
      end

      # WebM → MP3 変換
      _stdout, stderr, status = Open3.capture3(
        "ffmpeg", "-i", fixed_path,
        "-ar", "44100", "-ac", "2", "-b:a", "192k",
        mp3_path, "-y", "-loglevel", "quiet"
      )
      Rails.logger.error "ffmpeg (convert mp3) failed: #{stderr}" unless status.success?

      if File.exist?(mp3_path)
        converted_audio.attach(
          io: File.open(mp3_path),
          filename: "recording.mp3",
          content_type: "audio/mpeg"
        )
      end
    ensure # 一時ファイル（fixed.webm, output.mp3）をサーバーに残さない。
      File.delete(fixed_path) if File.exist?(fixed_path)
      File.delete(mp3_path)   if File.exist?(mp3_path)
    end
  end
end
