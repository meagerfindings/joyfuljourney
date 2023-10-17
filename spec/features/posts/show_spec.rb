require 'rails_helper'

RSpec.describe "Posts Show Page", type: :feature do
  let(:user) { User.create(first_name: "Elon", last_name: "Musk", birthdate: "June 28, 1971") }
  let(:post) { user.post.create(title: "Punny", body: "For the chemistry nerds: “Technically, alcohol is a solution.") }

  it "shows a specific post's details" do
    visit "posts/#{post.id}"

    within("h1") do
      expect(page).to have_content(post.title)
    end

    expect(page).to have_content("by: #{user.name}")
    expect(page).to have_content(post.body)
    expect(page).to have_link("Edit", href: edit_post_path(post))
    expect(page).to have_link("Destroy", href: post_path(post))
  end

  it "has a link back to posts index page" do
    visit "posts/#{post.id}"

    click_link 'Back to Posts'
    expect(page).to have_current_path('/posts')
  end
end
