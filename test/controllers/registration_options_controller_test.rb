require "test_helper"

class RegistrationOptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @registration_option = registration_options(:one)
  end

  test "should get index" do
    get registration_options_url
    assert_response :success
  end

  test "should get new" do
    get new_registration_option_url
    assert_response :success
  end

  test "should create registration_option" do
    assert_difference("RegistrationOption.count") do
      post registration_options_url, params: { registration_option: { closes_at: @registration_option.closes_at, collection_id: @registration_option.collection_id, description: @registration_option.description, opens_at: @registration_option.opens_at, title: @registration_option.title } }
    end

    assert_redirected_to registration_option_url(RegistrationOption.last)
  end

  test "should show registration_option" do
    get registration_option_url(@registration_option)
    assert_response :success
  end

  test "should get edit" do
    get edit_registration_option_url(@registration_option)
    assert_response :success
  end

  test "should update registration_option" do
    patch registration_option_url(@registration_option), params: { registration_option: { closes_at: @registration_option.closes_at, collection_id: @registration_option.collection_id, description: @registration_option.description, opens_at: @registration_option.opens_at, title: @registration_option.title } }
    assert_redirected_to registration_option_url(@registration_option)
  end

  test "should destroy registration_option" do
    assert_difference("RegistrationOption.count", -1) do
      delete registration_option_url(@registration_option)
    end

    assert_redirected_to registration_options_url
  end
end
