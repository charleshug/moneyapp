require "test_helper"

class BudgetsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get budgets_index_url
    assert_response :success
  end
end
