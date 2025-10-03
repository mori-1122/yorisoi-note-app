require "rails_helper"

RSpec.describe Recording, type: :model do
  describe "バリデーション" do
    context "webmファイルが添付されている場合" do
      let(:recording) do
        file = fixture_file_upload(file_fixture("sample.webm"), "audio/webm")
        build(:recording, audio_file: file)
      end

      it "録音が保存できる" do
        expect(recording.valid?).to be true
      end
    end

    context "ファイルが添付されていない場合" do
      let(:recording) { build(:recording, audio_file: nil) }

      it "録音を保存できない" do
        expect(recording.valid?).to be false
        expect(recording.errors[:audio_file]).to include("を入力してください")
      end
    end

    context "webm以外のファイルが添付されている場合" do
      let(:recording) do
        file = fixture_file_upload(file_fixture("dummy.txt"), "text/plain")
        build(:recording, audio_file: file)
      end

      it "許可されていない形式として弾かれる" do
        expect(recording.valid?).to be false
        expect(recording.errors[:audio_file]).to include("のファイルタイプは許可されていません (許可されたファイルタイプは)")
      end
    end
  end

  describe "after_commitコールバック" do
    context "正しい形式の音声ファイルを追加した場合" do
      let(:recording) do
        file = fixture_file_upload(file_fixture("sample.webm"), "audio/webm")
        create(:recording, audio_file: file, recorded_at: Time.current)
      end

      it "mp3ファイルに変換されて保存される" do
        expect(recording.converted_audio).to be_attached
        expect(recording.converted_audio.filename.to_s).to eq("recording.mp3")
      end

      it "音声の長さがメタデータに保存される" do
        expect(recording.audio_file.blob.metadata[:duration]).to be > 0
      end
    end

    context "2MB以上のファイルが添付されている場合" do
      let(:recording) do
        file = fixture_file_upload(file_fixture("big.webm"), "audio/webm")
        build(:recording, audio_file: file)
      end

      it "サイズ超過として保存できない" do
        expect(recording.valid?).to be false
        expect(recording.errors[:audio_file]).to include("のファイルサイズは2MB未満にしてください (添付ファイルのサイズは3MB)")
      end
    end

    context "ファイルの種類情報が不明な場合" do
      let(:recording) do
        # sample.webmを使いつつ、MIMEタイプをあえて不正なものにする
        file = fixture_file_upload(file_fixture("no_extension"), nil)
        build(:recording, audio_file: file)
      end

      it "保存できない" do
        expect(recording.valid?).to be false
      end

      it "ファイルタイプのエラーメッセージが追加される" do
        expect(recording.valid?).to be false
        expect(recording.errors[:audio_file]).to include(a_string_starting_with("のファイルタイプは許可されていません")
        )
      end
    end
  end

  describe "アソシエーション" do
    context "ユーザーが紐付いていない場合" do
      let(:recording) do
        file = fixture_file_upload(file_fixture("sample.webm"), "audio/webm")
        build(:recording, user: nil, audio_file: file)
      end

      it "録音は保存できない" do
        expect(recording.valid?).to be false
        expect(recording.errors[:user]).to include("を入力してください")
      end
    end

    context "visitが紐付いていない場合" do
      let(:recording) do
        file = fixture_file_upload(file_fixture("sample.webm"), "audio/webm")
        build(:recording, visit: nil, audio_file: file)
      end

      it "録音は保存できない" do
        expect(recording.valid?).to be false
        expect(recording.errors[:visit]).to include("を入力してください")
      end
    end
  end
end
