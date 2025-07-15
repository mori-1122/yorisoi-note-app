require "test_helper"

class VisitsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create!(
      email: "test2@example.com",
      password: "password",
      name: "テストユーザー"
    )

    sign_in @user

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

  test "should get index" do
    get visits_url
    assert_response :success
  end
end
