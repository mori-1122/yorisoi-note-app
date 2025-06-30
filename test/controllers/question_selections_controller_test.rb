require "test_helper"

class QuestionSelectionsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get question_selections_create_url
    assert_response :success
  end
end
