# app/helpers/recordings_helper.rb
module RecordingsHelper
  # 録音時間を「分秒」形式に変換して表示
  def format_duration(blob)
    # ファイルが存在しない、またはduration情報がない場合
    return "--分--秒" if blob.nil? || blob.metadata.nil? || blob.metadata["duration"].blank?

    # duration（録音時間：秒数）を整数にして分・秒に変換
    duration_in_seconds = blob.metadata["duration"].to_f.floor
    minutes = duration_in_seconds / 60
    seconds = duration_in_seconds % 60

    "#{minutes}分#{seconds}秒"
  end

  # 録音プレイヤーを表示（<audio>タグを生成）
  def audio_player(recording)
    # 録音データが存在しない場合は何も表示しない
    return "" if recording.nil?

    content_tag(:audio, id: "audioPlayer", controls: true) do
      sources = []

      # 優先順位：
      # ① 変換済みMP3ファイルがある場合 → MP3を使用
      # ② MP3がないが元の録音ファイルがある場合 → WebMなど元データを使用
      # ③ どちらもない場合 → ブラウザ非対応メッセージ
      if recording.converted_audio&.attached?
        sources << tag.source(
          src: rails_blob_path(recording.converted_audio, disposition: "inline"),
          type: "audio/mpeg"
        )

      elsif recording.audio_file&.attached?
        sources << tag.source(
          src: rails_blob_path(recording.audio_file, disposition: "inline"),
          type: recording.audio_file.content_type
        )

      else
        sources << "お使いのブラウザではサポートされていません。"
      end

      # 複数のタグを安全にHTMLとして結合して返す
      safe_join(sources)
    end
  end

  # 録音ファイルのサイズを人が読める形式（例: "1.2 MB"）で表示
  def recording_file_size(recording)
    # 録音データまたはファイルが存在しない場合
    return "--" if recording.nil? || !recording.audio_file&.attached?

    # ActiveStorageのヘルパーで自動的に「MB」「KB」などに変換
    number_to_human_size(recording.audio_file.byte_size)
  end
end
