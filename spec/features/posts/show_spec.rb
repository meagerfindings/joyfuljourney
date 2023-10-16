require 'rails_helper'

RSpec.describe "Posts Show Page", type: :feature do
  it "shows a specific post's details" do
    user = User.create(first_name: "Elon", last_name: "Musk", birthdate: "June 28, 1971")
    post = user.post.create(title: "Punny", body: "For the chemistry nerds: “Technically, alcohol is a solution.")

    visit "posts/#{post.id}"

    within("h1") do
      expect(page).to have_content(post.title)
    end

    expect(page).to have_content(post.body)
    expect(page).to have_link("Edit", href: edit_post_path(post))
    expect(page).to have_link("Destroy", href: post_path(post))
  end
end
