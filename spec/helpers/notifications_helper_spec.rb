require 'rails_helper'

RSpec.describe NotificationsHelper, type: :helper do
  describe "#format_due_date" do
    context "受診予定日が設定されている場合" do
      it "「2025年10月10日」形式で表示される" do
        date = Date.new(2025, 10, 10)
        expect(helper.format_due_date(date)).to eq "2025年10月10日"
      end
    end

    context "受診予定日が設定されていない場合" do
      it "「未定」と表示される" do
        expect(helper.format_due_date(nil)).to eq "未定"
      end

      it "空の場合も「未定」と表示される" do
        expect(helper.format_due_date("")).to eq "未定"
      end
    end
  end

  describe "#display_send_status" do
    context "通知が送信済みの場合" do
      it "「送信済み」と表示される" do
        expect(helper.display_send_status(true)).to eq "送信済み"
      end
    end

    context "通知が未送信の場合" do
      it "「未送信」と表示される" do
        expect(helper.display_send_status(false)).to eq "未送信"
      end
    end
  end
end
