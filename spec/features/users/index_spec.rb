require 'rails_helper'

RSpec.describe 'Users Index Page', type: :feature do
  let(:user_1) { User.create(first_name: 'Bart', last_name: 'Simpson', birthdate: 'April 1, 1990') }
  let(:user_2) { User.create(first_name: 'Sideshow', last_name: 'Bob', birthdate: 'January 1, 1960') }

  before(:each) do
    DatabaseCleaner.clean_with(:truncation)
    user_1.touch
    user_2.touch
  end

  it 'can see all users and their information' do
    visit '/users'

    expect(page).to have_content('All Users')

    within("#user-#{user_1.id}") do
      expect(page).to have_content(user_1.first_name)
      expect(page).to have_content(user_1.last_name)
      expect(page).to have_content(user_1.birthdate)
      expect(page).to have_content(user_1.created_at)
      expect(page).to have_link(user_1.name, href: user_path(user_1.id))
      expect(page).to have_link('Edit', href: edit_user_path(user_1.id))
    end

    within("#user-#{user_2.id}") do
      expect(page).to have_content(user_2.first_name)
      expect(page).to have_content(user_2.last_name)
      expect(page).to have_content(user_2.birthdate)
      expect(page).to have_content(user_2.created_at)
      expect(page).to have_link(user_2.name, href: user_path(user_2.id))
      expect(page).to have_link('Edit', href: edit_user_path(user_2.id))
    end
  end

  it 'displays users from most recently created to oldest' do
    visit '/users'

    users = page.all('li')
    expect(users.first).to have_content(user_2.name)
    expect(users.last).to have_content(user_1.name)
  end

  it 'has a link to create new users' do
    visit '/users'

    expect(page).to have_link('Create User', href: '/users/new')
    click_link 'Create User'

    expect(page).to have_current_path('/users/new')
  end
end
