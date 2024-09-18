require "application_system_test_case"

class RegistrationOptionsTest < ApplicationSystemTestCase
  setup do
    @registration_option = registration_options(:one)
  end

  test "visiting the index" do
    visit registration_options_url
    assert_selector "h1", text: "Registration options"
  end

  test "should create registration option" do
    visit registration_options_url
    click_on "New registration option"

    fill_in "Closes at", with: @registration_option.closes_at
    fill_in "Collection", with: @registration_option.collection_id
    fill_in "Description", with: @registration_option.description
    fill_in "Opens at", with: @registration_option.opens_at
    fill_in "Title", with: @registration_option.title
    click_on "Create Registration option"

    assert_text "Registration option was successfully created"
    click_on "Back"
  end

  test "should update Registration option" do
    visit registration_option_url(@registration_option)
    click_on "Edit this registration option", match: :first

    fill_in "Closes at", with: @registration_option.closes_at.to_s
    fill_in "Collection", with: @registration_option.collection_id
    fill_in "Description", with: @registration_option.description
    fill_in "Opens at", with: @registration_option.opens_at.to_s
    fill_in "Title", with: @registration_option.title
    click_on "Update Registration option"

    assert_text "Registration option was successfully updated"
    click_on "Back"
  end

  test "should destroy Registration option" do
    visit registration_option_url(@registration_option)
    click_on "Destroy this registration option", match: :first

    assert_text "Registration option was successfully destroyed"
  end
end
