require "rails_helper"

RSpec.describe Recording, type: :model do
  describe "バリデーション" do
    context "webmファイルが添付されている場合" do
      let(:recording) do
        file = fixture_file_upload(file_fixture("sample.webm"), "audio/webm")
        build(:recording, audio_file: file)
      end

      it "有効である" do
        expect(recording.valid?).to be true
      end
    end

    context "ファイルが添付されていない場合" do
      let(:recording) { build(:recording, audio_file: nil) }

      it "無効である" do
        expect(recording.valid?).to be false
        expect(recording.errors[:audio_file]).to include("を入力してください")
      end
    end

    context "webm以外のファイルが添付されている場合" do
      let(:recording) do
        file = fixture_file_upload(file_fixture("dummy.txt"), "text/plain")
        build(:recording, audio_file: file)
      end

      it "無効である" do
        expect(recording.valid?).to be false
        expect(recording.errors[:audio_file]).to include("のファイルタイプは許可されていません (許可されたファイルタイプは)")
      end
    end
  end

  describe "after_commitコールバック" do
    context "webmファイルをアップロードした場合" do
      let(:recording) do
        file = fixture_file_upload(file_fixture("sample.webm"), "audio/webm")
        create(:recording, audio_file: file, recorded_at: Time.current)
      end

      it "mp3に変換されて保存される" do
        expect(recording.converted_audio).to be_attached
        expect(recording.converted_audio.filename.to_s).to eq("recording.mp3")
      end

      it "durationがメタデータに保存される" do
        expect(recording.audio_file.blob.metadata[:duration]).to be > 0
      end
    end

    context "2MB以上のファイルが添付されている場合" do
      let(:recording) do
        file = fixture_file_upload(file_fixture("big.webm"), "audio/webm")
        build(:recording, audio_file: file)
      end

      it "無効である" do
        expect(recording.valid?).to be false
        expect(recording.errors[:audio_file]).to include("のファイルサイズは2MB未満にしてください (添付ファイルのサイズは3MB)")
      end
    end

    context "content_typeが空な場合" do
      let(:recording) do
        # sample.webmを使いつつ、MIMEタイプをあえて不正なものにする
        file = fixture_file_upload(file_fixture("no_extension"), nil)
        build(:recording, audio_file: file)
      end

      it "無効である" do
        expect(recording.valid?).to be false
      end

      it "audio_fileのタイプエラーが追加される" do
        expect(recording.valid?).to be false
        expect(recording.errors[:audio_file]).to include(a_string_starting_with("のファイルタイプは許可されていません")
        )
      end
    end
  end

  describe "アソシエーション" do
    context "userが紐付いていない場合" do
      let(:recording) do
        file = fixture_file_upload(file_fixture("sample.webm"), "audio/webm")
        build(:recording, user: nil, audio_file: file)
      end

      it "無効である" do
        expect(recording.valid?).to be false
        expect(recording.errors[:user]).to include("を入力してください")
      end
    end

    context "visitが紐付いていない場合" do
      let(:recording) do
        file = fixture_file_upload(file_fixture("sample.webm"), "audio/webm")
        build(:recording, visit: nil, audio_file: file)
      end

      it "無効である" do
        expect(recording.valid?).to be false
        expect(recording.errors[:visit]).to include("を入力してください")
      end
    end
  end
end
