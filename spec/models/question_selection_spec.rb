require 'rails_helper'

RSpec.describe QuestionSelection, type: :model do
  describe "バリデーション" do
    let(:user) { create(:user) }
    let(:visit) { create(:visit) }
    let(:question) { create(:question) }

    context "全ての情報が正しい場合" do
      let(:selection) { build(:question_selection, user: user, visit: visit, question: question, selected_at: Time.current) }

      it "質問を登録できる" do
        expect(selection.valid?).to be true
      end
    end

    context "選択日時が未設定の場合" do
      let(:selection) { build(:question_selection, user: user, visit: visit, question: question, selected_at: nil) }

      it "登録できない" do
        expect(selection.valid?).to be false
        expect(selection.errors[:selected_at]).to include("を入力してください")
      end
    end

    context "同じ受診予定に同じ質問を重複して登録する場合" do
      let!(:first_selection) { create(:question_selection, user: user, visit: visit, question: question) }
      let(:duplicate) { build(:question_selection, user: user, visit: visit, question: question) }

      it "重複登録できない" do
        expect(duplicate.valid?).to be false
        expect(duplicate.errors[:question_id]).to include("は、この予定にすでに登録されています")
      end
    end
  end
end
