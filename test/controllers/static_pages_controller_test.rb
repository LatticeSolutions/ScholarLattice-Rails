require "test_helper"

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  test "should get privacy" do
    get static_pages_privacy_url
    assert_response :success
  end

  test "should get tos" do
    get static_pages_tos_url
    assert_response :success
  end
end
