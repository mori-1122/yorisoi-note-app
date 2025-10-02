FactoryBot.define do
  factory :recording do
    association :user
    association :visit
    recorded_at { Time.current }
  end
end

# デフォルトでaudio_fileを付けないのは、不要なテストでも重い処理を強制しないため
