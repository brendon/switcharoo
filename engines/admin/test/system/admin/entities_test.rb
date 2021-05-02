require "application_system_test_case"

module Admin
  class EntitiesTest < ApplicationSystemTestCase
    setup do
      @entity = admin_entities(:one)
    end

    test "visiting the index" do
      visit entities_url
      assert_selector "h1", text: "Entities"
    end

    test "creating a Entity" do
      visit entities_url
      click_on "New Entity"

      fill_in "Database", with: @entity.database
      fill_in "Domain", with: @entity.domain
      fill_in "Name", with: @entity.name
      click_on "Create Entity"

      assert_text "Entity was successfully created"
      click_on "Back"
    end

    test "updating a Entity" do
      visit entities_url
      click_on "Edit", match: :first

      fill_in "Database", with: @entity.database
      fill_in "Domain", with: @entity.domain
      fill_in "Name", with: @entity.name
      click_on "Update Entity"

      assert_text "Entity was successfully updated"
      click_on "Back"
    end

    test "destroying a Entity" do
      visit entities_url
      page.accept_confirm do
        click_on "Destroy", match: :first
      end

      assert_text "Entity was successfully destroyed"
    end
  end
end