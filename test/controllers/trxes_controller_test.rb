require "test_helper"

class TrxesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get trxes_new_url
    assert_response :success
  end

  test "should get edit" do
    get trxes_edit_url
    assert_response :success
  end

  test "should get index" do
    get trxes_index_url
    assert_response :success
  end
end
