require "open3" # ffprobeを使うので、Open3の記載が必要らしい

class RecordingsController < ApplicationController # 録音に関するリクエストを処理するコントローラ
  before_action :authenticate_user! # ユーザーがログインしているか確認
  before_action :set_visit # コントローラの各アクションの前に、対応する Visit（診察記録）を取得して@visitにセット

  def new # 録音がまだ存在しなければ新しく作る。診療をする際に録音機能も作成する
    @recording = @visit.recording || @visit.build_recording # 録音がまだ存在しなければ新しく作る。診療をする際に録音機能も作成する
  end

  def create
    @recording = @visit.build_recording( # visit_idの整合性を自動で担保（外部キーの手動セットを不要にする）
      user: current_user, # アクセスユーザを明示的に紐付け（監査のため・不正な代理アップロード防止）
      recorded_at: Time.current, # DBはUTC保存が一般的。Time.currentでUTC変換が一貫して行われる
      audio_file: params[:audio] # JSからの直接アップロードを受けるケース。Strong Parameters前提ならpermitで包む
    )

    # ①レコード保存（メタ情報含むDB整合性を確保） ②ファイルが確実に添付されているか検証
    if @recording.save && @recording.audio_file.attached?
      # 外部コマンド(FFprobe)は失敗し得るため、別メソッドに分離して例外や失敗を0秒として吸収
      duration = fetch_audio_duration(@recording.audio_file)

      # ActiveStorageのメタデータに再生時間を格納（後段のUIで波形や再生バー表示に使える）
      @recording.audio_file.blob.update(
        metadata: @recording.audio_file.blob.metadata.merge(custom_duration: duration)
      )

      # SPA的に扱うためJSONで成功レスポンス→クライアント側で画面遷移
      render json: { status: "OK", redirect_url: visit_recording_path(@visit) }
    else
      # バリデーション失敗や添付無しを明示。422を返す
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


  # current_user コープで検索する
  # 例: current_user.visits.find(params[:visit_id])
  # 他人のvisit_idを推測されてもアクセス不能にできる
  def set_visit
    @visit = Visit.find(params[:visit_id])
  end

  # FFprobeで音声の長さ(秒)を取得する
  def fetch_audio_duration(file)
    file.open(tmpdir: Dir.tmpdir) do |f| # ActiveStorageのblob.openは、S3の場合も 一時的にローカルファイルへダウンロードしてから渡してくれるらしい。tmpdir:を指定することで、一時ファイルが安全にOSのテンポラリディレクトリに作られる。
      stdout, stderr, status = Open3.capture3( # stdout → コマンドが通常出力した文字列。stderr → エラー出力の文字列。status → プロセスの終了ステータスを表す Process::Status オブジェクト。
        "ffprobe", "-i", f.path, "-show_entries", "format=duration",
        "-v", "quiet", "-of", "csv=p=0" # -v quiet → ログを抑制。-show_entries format=duration → フォーマット情報から duration だけを取り出す。-of csv=p=0 → 出力を CSV 形式でシンプルに数値のみ取得。
      )
      status.success? ? stdout.to_f.round : 0  # ffprobeが正常終了しない場合（ファイル破損・非対応形式など）に例外を投げず、0 を返すようにしている。
    end
  end
end
