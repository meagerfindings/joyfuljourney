require 'rails_helper'

RSpec.describe "Posts Edit Page", type: :feature do
  let(:user) { User.create(first_name: "BNNY", last_name: "RBBT", birthdate: "June 20, 1980") }
  let(:post) { user.post.create(title: "If I Were Human", body: "If I were human, I'd wake up everyday a new man.") }

  before(:each) do
    DatabaseCleaner.clean_with(:truncation)
  end

  it "allows modification of existing post's information" do
    edited_post = {
      title: "I Hate Love",
      body: "My cup was full up to the brim, but the leak at the bottom let the emptiness in."
    }

    visit "posts/#{post.id}/edit"

    within("h1") do
      expect(page).to have_content("Edit #{ post.title}")
    end

    within("#post-edit-details") do
      fill_in 'Title', with: edited_post[:title]
      fill_in 'Body', with: edited_post[:body]
    end

    click_button 'Update Post'

    expect(current_path).to eq("/posts/#{post.id}")

    within("h1") do
      expect(page).to have_content(edited_post[:title])
    end

    within("#post-details") do
      expect(page).to have_content(edited_post[:body])
    end

  end

  it 'displays error messages for empty fields' do
    visit "/posts/#{post.id}/edit"

    within("#post-edit-details") do
      fill_in 'Title', with: ''
      fill_in 'Body', with: ''
    end

    click_button 'Update Post'
    expect(page).to have_content("Title can't be blank")
    expect(page).to have_content("Body is too short (minimum is 10 characters)")
  end
end
