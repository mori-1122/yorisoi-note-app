FactoryBot.define do
  factory :document do
    association :user
    association :visit
    doc_type { :medical_record } # バリデーションでdoc_typeが必須だから、デフォルト値をセットしておく

    image { Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/test_image.jpg"), "image/jpeg") }
  end
end
