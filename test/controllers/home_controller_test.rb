require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should show home when not logged in" do
    get root_url
    assert_response :success
  end
end
