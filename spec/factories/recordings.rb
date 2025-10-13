FactoryBot.define do
  factory :recording do
    association :user
    association :visit
    recorded_at { Time.current }

    # コールバックを使わない
    # 音声ファイルが必要なtestの際に使用する
    trait :with_audio do
      audio_file do
        Rack::Test::UploadedFile.new(
          Rails.root.join("spec/fixtures/files/sample.webm"),
          "audio/webm"
        )
      end
    end
  end
end
