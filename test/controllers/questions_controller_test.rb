require "test_helper"

class QuestionsControllerTest < ActionDispatch::IntegrationTest
  test "should get select" do
    get questions_select_url
    assert_response :success
  end

  test "should get search" do
    get questions_search_url
    assert_response :success
  end
end
