require 'rails_helper'

RSpec.describe Question, type: :model do
  describe "バリデーション" do
    context "質問内容が入力されている場合" do
      let(:question) { build(:question, content: "家で測った血圧が高めです", department:, question_category: category) }
      let(:category) { create(:question_category) }
      let(:department) { create(:department) }

      it "登録できる" do
        expect(question.valid?).to be true
      end
    end

    context "質問内容が空の場合" do
      let(:department) { create(:department) }
      let(:category) { create(:question_category) }
      let(:question) { build(:question, content: "", department:, question_category: category) }

      it "登録できない" do
        expect(question.valid?).to be false
        expect(question.errors[:content]).to include("を入力してください")
      end
    end

    context "同じ診療科・カテゴリ内で質問内容が重複している場合" do
      let(:department) { create(:department) }
      let(:category) { create(:question_category) }
      let(:existing_question) { create(:question, content: "この薬は続けて飲んでも大丈夫ですか", department:, question_category: category) }
      let(:duplicate_question) { build(:question, content: "この薬は続けて飲んでも大丈夫ですか", department:, question_category: category) }

      it "登録できない" do
        existing_question
        expect(duplicate_question.valid?).to be false
        expect(duplicate_question.errors[:content]).to include("は、同じ診療科、カテゴリにすでにあります")
      end
    end

    context "カテゴリが異なる場合" do
      let(:department) { create(:department) }
      let(:other_department) { create(:department) }
      let(:category) { create(:question_category) }
      let(:existing_question) { create(:question, content: "検査結果はいつわかりますか", department:, question_category: category) }
      let(:new_question) { build(:question, content: "検査結果はいつわかりますか", department: other_department, question_category: category) }

      it "登録できる" do
        expect(new_question.valid?).to be true
      end
    end

    context "診療科・カテゴリの指定" do
      let(:question) { build(:question, content: "この薬は飲み続けても大丈夫ですか", department: nil, question_category: nil) }

      it "どちらも指定されていない場合は登録できない" do
        expect(question.valid?).to be false
        expect(question.errors[:base]).to include("診療科に関する質問、またはカテゴリの質問のどちらかを選んでください")
      end
    end
  end
end
