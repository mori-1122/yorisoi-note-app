
require "test_helper"

class VisitsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create!(
      name: "テストユーザー",
      email: "test@testtest.com",
      password: "password"
    )

    @department = Department.create!(name: "内科")

    @visit = Visit.create!(
      user: @user,
      department: @department,
      hospital_name: "テスト病院",
      purpose: "検査",
      appointed_at: Time.current,
      visit_date: Date.today
    )
  end
end
