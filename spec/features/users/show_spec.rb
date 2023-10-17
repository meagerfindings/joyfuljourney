require 'rails_helper'

RSpec.describe "User Show Page", type: :feature do
  before(:each) do
    DatabaseCleaner.clean_with(:truncation)
  end

  let(:user) { User.create(first_name: "William", middle_name: "Unknown", last_name: "Ramos", birthdate: "January 1, 1993", nickname: "Sunshine") }

  it "displays given users complete information" do
    visit "/users/#{user.id}"

    within("#header-name") do
      expect(page).to have_content(user.name)
    end

    within("#user-details") do
      expect(page).to have_content(user.first_name)
      expect(page).to have_content(user.middle_name)
      expect(page).to have_content(user.last_name)
      expect(page).to have_content(user.birthdate)
      expect(page).to have_content(user.nickname)
    end
  end

  it "has a link back to users index" do
    visit "/users/#{user.id}"

    expect(page).to have_link("All Users")
    click_link 'All Users'
    expect(page).to have_current_path('/users')
    end

  it "has a link back to edit user page" do
    visit "/users/#{user.id}"

    click_link 'Edit User'
    expect(page).to have_current_path("/users/#{user.id}/edit")
  end
end
