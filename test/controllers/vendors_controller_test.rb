require "test_helper"

class VendorsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get vendors_index_url
    assert_response :success
  end

  test "should get new" do
    get vendors_new_url
    assert_response :success
  end

  test "should get edit" do
    get vendors_edit_url
    assert_response :success
  end
end
