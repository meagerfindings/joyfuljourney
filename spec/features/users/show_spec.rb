require 'rails_helper'

RSpec.describe "User Show Page", type: :feature do
  it "displays given users complete information" do
    user_1 = User.create(first_name: "William", middle_name: "Unknown", last_name: "Ramos", birthdate: "January 1, 1993", nickname: "Sunshine")

    visit "/users/#{user_1.id}"

    within("#header-name") do
      expect(page).to have_content(user_1.name)
    end

    within("#user-details") do
      expect(page).to have_content(user_1.first_name)
      expect(page).to have_content(user_1.middle_name)
      expect(page).to have_content(user_1.last_name)
      expect(page).to have_content(user_1.birthdate)
      expect(page).to have_content(user_1.nickname)
    end
  end

  it "has a link back to users index" do
    user_1 = User.create(first_name: "William", middle_name: "Unknown", last_name: "Ramos", birthdate: "January 1, 1993", nickname: "Sunshine")

    visit "/users/#{user_1.id}"
    expect(page).to have_link("All Users")
    click_link 'All Users'
    expect(page).to have_current_path('/users')
    end

  it "has a link back to edit user page" do
    user_1 = User.create(first_name: "William", middle_name: "Unknown", last_name: "Ramos", birthdate: "January 1, 1993", nickname: "Sunshine")

    visit "/users/#{user_1.id}"
    click_link 'Edit User'
    expect(page).to have_current_path("/users/#{user_1.id}/edit")
  end
end
