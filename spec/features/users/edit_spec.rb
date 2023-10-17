require 'rails_helper'

RSpec.describe "User Edit Page", type: :feature do
  let(:user) {
    User.create(first_name: "William", middle_name: "Unknown", last_name: "Ramos",
                birthdate: "January 1, 1993", nickname: "Sunshine")
  }

  before(:each) do
    DatabaseCleaner.clean_with(:truncation)
  end

  it "allows modification of existing user's information" do
    edited_user = {
      first_name: "George",
      middle_name: "Michael",
      last_name: "Bluth",
      birthdate: "1990-01-01",
      nickname: "George-Michael"
    }

    visit "/users/#{user.id}/edit"

    within("#header-name") do
      expect(page).to have_content("Edit #{user.name}")
    end

    within("#user-edit-details") do
      fill_in 'First name', with: edited_user[:first_name]
      fill_in 'Middle name', with: edited_user[:middle_name]
      fill_in 'Last name', with: edited_user[:last_name]
      fill_in 'Nickname', with: edited_user[:nickname]
      fill_in 'Birthdate', with: edited_user[:birthdate]
    end

    click_button 'Update User'

    expect(current_path).to eq("/users/#{user.id}")

    within("#user-details") do
      expect(page).to have_content(edited_user[:first_name])
      expect(page).to have_content(edited_user[:middle_name])
      expect(page).to have_content(edited_user[:last_name])
      expect(page).to have_content(edited_user[:birthdate])
      expect(page).to have_content(edited_user[:nickname])
    end
  end

  it 'displays error messages for empty fields' do
    visit "/users/#{user.id}/edit"

    within("#user-edit-details") do
      fill_in 'First name', with: ''
      fill_in 'Last name', with: ''
    end

    click_button 'Update User'
    expect(page).to have_content("First name can't be blank")
    expect(page).to have_content("Last name can't be blank")
  end
end
