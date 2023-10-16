require 'rails_helper'

RSpec.describe "Users Index Page", type: :feature do
  it "can see all users, their name, and date of birth" do
    user_1 = User.create(first_name: "Bart", last_name: "Simpson", birthdate: "April 1, 1990")
    user_2 = User.create(first_name: "Sideshow", last_name: "Bob", birthdate: "January 1, 1960")

    visit "/users"

    expect(page).to have_content("All Users")

    within("#user-#{user_1.id}") do
      expect(page).to have_content(user_1.first_name)
      expect(page).to have_content(user_1.last_name)
      expect(page).to have_content(user_1.birthdate)
      expect(page).to have_link(user_1.name, href: user_path(user_1.id))
      expect(page).to have_link('Edit', href: edit_user_path(user_1.id))
    end

    within("#user-#{user_2.id}") do
      expect(page).to have_content(user_2.first_name)
      expect(page).to have_content(user_2.last_name)
      expect(page).to have_content(user_2.birthdate)
      expect(page).to have_link(user_2.name, href: user_path(user_2.id))
      expect(page).to have_link('Edit', href: edit_user_path(user_2.id))
    end
  end
end