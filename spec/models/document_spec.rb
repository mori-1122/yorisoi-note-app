require 'rails_helper'

RSpec.describe Document, type: :model do
  describe "バリデーション" do
    let(:user)  { create(:user) }
    let(:visit) { create(:visit) }

    context "全ての情報が正しい場合" do
      let(:document) { build(:document, user: user, visit: visit) }

      it "画像を保存できる" do
        expect(document.valid?).to be true
      end
    end

    context "画像が添付されていない場合" do
      let(:document) { build(:document, user: user, visit: visit, image: nil) }

      it "保存できない" do
        expect(document.valid?).to be false
        expect(document.errors[:image]).to include("を入力してください")
      end
    end

    context "不正なファイル形式の画像が添付されている場合" do
      let(:file) { fixture_file_upload("spec/fixtures/files/dummy.txt", "text/plain") }
      let(:document) { build(:document, user: user, visit: visit, image: file) }

      it "保存できない" do
        expect(document.valid?).to be false
        expect(document.errors[:image]).to include("のファイルタイプは許可されていません (許可されたファイルタイプはPNG, JPG, GIF)")
      end
    end

    context "書類タイプ(doc_type)が設定されていない場合" do
      let(:document) { build(:document, user: user, visit: visit, doc_type: nil) }

      it "保存できない" do
        expect(document.valid?).to be false
        expect(document.errors[:doc_type]).to include("を入力してください")
      end
    end
  end
end
