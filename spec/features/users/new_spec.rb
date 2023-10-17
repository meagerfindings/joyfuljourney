require 'rails_helper'

RSpec.describe "New User Page", type: :feature do
  before(:each) do
    DatabaseCleaner.clean_with(:truncation)
  end

  it "allows the creation of a new user" do
    new_user = {
      first_name: "Joseph",
      middle_name: "Unknown",
      last_name: "Prusa",
      birthdate: "1887-08-03",
      nickname: "Printable"
    }

    visit "/users/new"

    within(".header") do
      expect(page).to have_content("New User")
    end

    within("#user-edit-details") do
      fill_in 'First name', with: new_user[:first_name]
      fill_in 'Middle name', with: new_user[:middle_name]
      fill_in 'Last name', with: new_user[:last_name]
      fill_in 'Nickname', with: new_user[:nickname]
      fill_in 'Birthdate', with: new_user[:birthdate]
    end

    click_button 'Create User'

    within("#user-details") do
      expect(page).to have_content(new_user[:first_name])
      expect(page).to have_content(new_user[:middle_name])
      expect(page).to have_content(new_user[:last_name])
      expect(page).to have_content(new_user[:birthdate])
      expect(page).to have_content(new_user[:nickname])
    end
  end

  it 'displays error messages for empty fields' do
    visit "/users/new"

    within("#user-edit-details") do
      fill_in 'First name', with: ''
      fill_in 'Last name', with: ''
    end

    click_button 'Create User'
    expect(page).to have_content("First name can't be blank")
    expect(page).to have_content("Last name can't be blank")
  end
end
