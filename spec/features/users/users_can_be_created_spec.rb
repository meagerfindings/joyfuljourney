require 'rails_helper'
require 'uri'

RSpec.describe 'User registration form' do
  before(:each) do
    DatabaseCleaner.clean_with(:truncation)
  end

  it 'creates new user' do
    visit root_path

    click_on 'Sign Up'

    username = 'Creepio'
    password = 'funzone'
    first_name = username
    last_name = 'Skywalker'

    fill_in :user_username, with: username
    fill_in :user_password, with: password
    fill_in :user_first_name, with: first_name
    fill_in :user_last_name, with: last_name

    click_on 'Create User'

    expect(page).to have_current_path(root_path)
    expect(page).to have_content("Welcome, #{first_name} #{last_name}!")
  end
end
