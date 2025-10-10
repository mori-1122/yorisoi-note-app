# spec/helpers/recordings_helper_spec.rb
require "rails_helper"

RSpec.describe RecordingsHelper, type: :helper do
  describe "#format_duration" do
    context "録音時間が取得できる場合" do
      it "『2分5秒』と表示される" do
        blob = ActiveStorage::Blob.new(metadata: { "duration" => 125.6 })
        expect(helper.format_duration(blob)).to eq("2分5秒")
      end
    end

    context "録音時間が未設定の場合" do
      it "『--分--秒』と表示される" do
        blob = ActiveStorage::Blob.new(metadata: {})
        expect(helper.format_duration(blob)).to eq("--分--秒")
      end
    end

    context "録音ファイルが存在しない場合" do
      it "『--分--秒』と表示される" do
        expect(helper.format_duration(nil)).to eq("--分--秒")
      end
    end
  end

  describe "#audio_player" do
    context "録音データが存在しない場合" do
      it "空文字を返す" do
        expect(helper.audio_player(nil)).to eq("")
      end
    end

    context "録音データと変換済み音声が両方ある場合" do
      it "audioタグを表示する" do
        recording = instance_double("Recording")
        converted_audio = double("ActiveStorage::Attached::One", attached?: true)
        audio_blob = instance_double("ActiveStorage::Blob", content_type: "audio/mpeg")
        audio_file = double("ActiveStorage::Attached::One", attached?: true, blob: audio_blob)

        allow(helper).to receive(:rails_blob_path).and_return("/rails/active_storage/blobs/test.mp3")
        allow(recording).to receive(:converted_audio).and_return(converted_audio)
        allow(recording).to receive(:audio_file).and_return(audio_file)
        allow(converted_audio).to receive(:blob).and_return(audio_blob)

        html = helper.audio_player(recording)
        expect(html).to include("<audio")
        expect(html).to include("<source")
        expect(html).to include("controls")
      end
    end

    context "どちらの音声ファイルも存在しない場合" do
      it "警告メッセージを含む" do
        recording = instance_double("Recording")
        converted_audio = double("ActiveStorage::Attached::One", attached?: false)
        audio_file = double("ActiveStorage::Attached::One", attached?: false)

        allow(recording).to receive(:converted_audio).and_return(converted_audio)
        allow(recording).to receive(:audio_file).and_return(audio_file)

        html = helper.audio_player(recording)
        expect(html).to include("お使いのブラウザではサポートされていません")
      end
    end
  end

  describe "#recording_file_size" do
    context "録音ファイルが添付されている場合" do
      it "『1.18MB』と表示される" do
        recording = instance_double("Recording")
        audio_blob = instance_double("ActiveStorage::Blob", byte_size: 1_234_567)
        audio_file = double("ActiveStorage::Attached::One", attached?: true, blob: audio_blob)

        allow(audio_file).to receive(:byte_size).and_return(audio_blob.byte_size)
        allow(recording).to receive(:audio_file).and_return(audio_file)

        expect(helper.recording_file_size(recording)).to eq("1.18MB")
      end
    end

    context "録音ファイルが添付されていない場合" do
      it "『--』と表示される" do
        recording = instance_double("Recording")
        audio_file = double("ActiveStorage::Attached::One", attached?: false)
        allow(recording).to receive(:audio_file).and_return(audio_file)

        expect(helper.recording_file_size(recording)).to eq("--")
      end
    end

    context "recordingがnilの場合" do
      it "『--』と表示される" do
        expect(helper.recording_file_size(nil)).to eq("--")
      end
    end
  end
end
