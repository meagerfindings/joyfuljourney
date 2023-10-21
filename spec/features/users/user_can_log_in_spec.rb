require 'rails_helper'

RSpec.describe "Logging In" do
  before(:each) do
    DatabaseCleaner.clean_with(:truncation)
  end

  let(:user) { create(:claimed_user) }

  it "can log in with valid credentials" do
    visit root_path

    click_on "Log In"

    expect(current_path).to eq(login_path)

    fill_in :username, with: user.username
    fill_in :password, with: user.password

    click_on "Log In"

    expect(current_path).to eq(root_path)

    expect(page).to have_content("Welcome, #{user.username}")
  end

  it "cannot log in with bad credentials" do
    visit login_path

    fill_in :username, with: user.username
    fill_in :password, with: "incorrect password"

    click_on "Log In"

    expect(current_path).to eq(login_path)

    expect(page).to have_content('Sorry, your username or password did not match what we have on record.')
  end

  context 'when signed in' do
    it "shows logout" do
      visit login_path

      expect(current_path).to eq(login_path)

      fill_in :username, with: user.username
      fill_in :password, with: user.password

      click_on "Log In"

      expect(current_path).to eq(root_path)
      expect(page).to have_content("Log Out")
    end

    it "does not show sign up / login" do
      visit login_path

      expect(current_path).to eq(login_path)

      fill_in :username, with: user.username
      fill_in :password, with: user.password

      click_on "Log In"

      expect(current_path).to eq(root_path)
      expect(page).to_not have_content("Sign Up")
      expect(page).to_not have_content("Log In")
    end
  end

  context 'when signed out' do
    it "does not show logout" do
      visit root_path
      expect(page).to_not have_content("Log Out")
    end

    it "does not show sign up / login" do
      visit root_path
      expect(page).to have_content("Sign Up")
      expect(page).to have_content("Log In")
    end
  end
end
