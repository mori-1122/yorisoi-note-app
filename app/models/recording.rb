class Recording < ApplicationRecord
  belongs_to :user
  belongs_to :visit

  has_one_attached :audio_file
  has_one_attached :converted_audio

  validates :audio_file,
            attached: true,
            content_type: [ "audio/webm" ],
            size: { less_than: 2.megabytes }

  after_commit :add_duration_and_convert, on: :create

  private

  def add_duration_and_convert
    return unless audio_file.attached?

    require "open3"
    require "pathname"

    Tempfile.create([ "recording", ".webm" ]) do |tempfile|
      tempfile.binmode
      tempfile.write(audio_file.download)
      tempfile.flush

      fixed_path = Pathname.new("#{tempfile.path}.fixed.webm")
      mp3_path   = Pathname.new("#{tempfile.path}.mp3")

      # duration補正（ffmpegでコンテナ再構築）
      system("ffmpeg", "-i", tempfile.path.to_s, "-c", "copy",
             fixed_path.to_path, "-y", "-loglevel", "quiet")

      # duration取得（ffprobeでメタデータ抽出）
      stdout, _stderr, _status = Open3.capture3(
        { "LANG" => "C" },
        "ffprobe",
        "-i", fixed_path.to_path,
        "-show_entries", "format=duration",
        "-v", "quiet",
        "-of", "csv=p=0"
      )

      duration = stdout.to_f
      if duration.positive?
        audio_file.blob.update!(
          metadata: audio_file.blob.metadata.merge(duration: duration)
        )
      end

      # MP3変換
      system("ffmpeg", "-i", fixed_path.to_path, "-ar", "44100", "-ac", "2",
             "-b:a", "192k", mp3_path.to_path, "-y", "-loglevel", "quiet")

      if mp3_path.exist?
        converted_audio.attach(
          io: File.open(mp3_path),
          filename: "recording.mp3",
          content_type: "audio/mpeg"
        )
      end

      # 一時ファイル削除
      [ fixed_path, mp3_path ].each { |f| f.delete if f.exist? }
    end
  end
end
