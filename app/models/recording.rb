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

    # S3対応：ファイルを一時的にローカルに保存
    Tempfile.create([ "recording", ".webm" ]) do |tempfile|
      tempfile.binmode
      tempfile.write(audio_file.download)
      tempfile.flush

      fixed_path = "#{tempfile.path}.fixed.webm"
      mp3_path   = "#{tempfile.path}.mp3"

      # duration補正
      system("ffmpeg -i #{tempfile.path} -c copy #{fixed_path} -y -loglevel quiet")

      # duration取得
      duration = `ffprobe -i #{fixed_path} -show_entries format=duration -v quiet -of csv=p=0`.to_f
      audio_file.blob.update(metadata: audio_file.blob.metadata.merge(duration: duration)) if duration.positive?

      # MP3変換
      system("ffmpeg -i #{fixed_path} -ar 44100 -ac 2 -b:a 192k #{mp3_path} -y -loglevel quiet")

      if File.exist?(mp3_path)
        converted_audio.attach(
          io: File.open(mp3_path),
          filename: "recording.mp3",
          content_type: "audio/mpeg"
        )
      end
    ensure
      File.delete(fixed_path) if File.exist?(fixed_path)
      File.delete(mp3_path) if File.exist?(mp3_path)
    end
  end
end
