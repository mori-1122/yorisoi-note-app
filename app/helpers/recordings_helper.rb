# ヘルパーはモジュールと書く
module RecordingsHelper
  def format_duration(blob)
    if blob&.metadata["duration"].present? # blobがnilではなく、さらに metadata["duration"] が存在しているかを確認。&. は安全ナビゲーション演算子。blobがnilも例外にならずnilを返す。
      d = blob.metadata["duration"].to_f # なぜか+１秒されるので、小数点を四捨五入
      seconds = d.floor
      "#{seconds / 60}分#{seconds % 60}秒"
    else
      "--分--秒" # durationが存在しない場合 "--分--秒" を返すことでview崩れを防ぐ
    end
  end

  def audio_player(recording) # Recordingモデルのインスタンス
    return "" unless recording # viewに<audio>タグが出ないようにする 早期リターン RailsのviewヘルパーはHTMLを返すため、空文字を返せば何もレンダリングされない

    content_tag(:audio, id: "audioPlayer", controls: true) do # HTMLタグを生成 controls: trueでブラウザの音声再生コントローラを表示
      sources = [] # Railsで複数のタグを安全に連結する場合 safe_join を使うのが推奨
      if recording.converted_audio.attached? # ActiveStorageのattached?メソッドでファイルがあるかを確認
        sources << tag.source( # tag.source で <source> タグを生成
          src: rails_blob_path(recording.converted_audio, disposition: "inline"), # disposition: "inline" により、ダウンロードではなくブラウザ内で再生可能
          type: "audio/mpeg" # ファイルのMIMEタイプを指定
        )
      end

      if recording.audio_file.attached? # 元の録音データが添付されていれば、<source>として追加。
        sources << tag.source(
          src: rails_blob_path(recording.audio_file, disposition: "inline"),
          type: recording.audio_file.content_type # アップロードされた形式に合わせて正しいMIMEタイプが埋め込まれる。
        )
      end

      sources << "お使いのブラウザではサポートされていません。"
      safe_join(sources) # safe_joinで配列の中身を安全に連結して返す
    end
  end

  # 録音ファイルサイズを変換
  def recording_file_size(recording)
    return "--" unless recording&.audio_file.attached? # &.はぼっち演算子。recording が nilの場合でも例外を出さないでnilを返す。.attachedは実際にDBに紐づいているかを真偽値で返す。
    number_to_human_size(recording.audio_file.byte_size) # ActiveStorage::Attachedオブジェクトが持つメソッド。バイト数（整数値）を返す
  end # number_to_human_sizeは、number_to_human_size
end
