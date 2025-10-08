require 'rails_helper'

RSpec.describe VisitsHelper, type: :helper do
  describe "#format_visit_date" do
    context "日付がある場合" do
      it "YYYY年M月D日形式で返す" do
        date = Date.new(2025, 10, 9)
        expect(helper.format_visit_date(date)).to eq "2025年10月9日"
      end
    end

    context "日付が入力されていない場合" do
      it "「未定」と表示される" do
        expect(helper.format_visit_date(nil)).to eq "未定"
      end

      it "日付が空の場合も「未定」と表示される" do
        expect(helper.format_visit_date("")).to eq "未定"
      end
    end
  end

  describe "#format_appointed_time" do
    context "受診予定時間が入力されている場合" do
      it "「9:30」のように時刻が表示される" do
        time = Time.zone.parse("2025-10-09 09:30")
        expect(helper.format_appointed_time(time)).to eq "09:30"
      end
    end

    context "受診予定時間が入力されていない場合" do
      it "「--:--」と表示される" do
        expect(helper.format_appointed_time(nil)).to eq "--:--"
      end

      it "空欄の時も「--:--」と表示される" do
        expect(helper.format_appointed_time("")).to eq "--:--"
      end
    end
  end

  describe "#display_hospital_name" do
    context "病院名が入力されている場合" do
      it "登録された病院名が表示される" do
        expect(helper.display_hospital_name("東京病院")).to eq "東京病院"
      end
    end

    context "病院名が入力されていない場合" do
      it "病院名が設定されていない場合は「未登録」と表示される" do
        expect(helper.display_hospital_name(nil)).to eq "(未登録)"
      end

      it "病院名が空の時も「未登録」と表示される" do
        expect(helper.display_hospital_name("")).to eq "(未登録)"
      end
    end
  end
end
