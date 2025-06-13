require 'rails_helper'

RSpec.describe "Navbar Partial", type: :feature do
  before(:each) do
    DatabaseCleaner.clean_with(:truncation)
  end

  it "shows on 'every' page" do
    user = User.create(first_name: "James", last_name: "Holden", birthdate: "August 8, 3333")
    post = user.posts.create(title: "Information Freedom", body: "Right, no coffee. This is a terrible planet.")

    routes_array = [
      '/users',
      "users/#{user.id}",
      "users/#{user.id}/edit",
      "users/new",
      "users/#{user.id}/posts",
      "posts",
      "posts/new",
      "posts/#{post.id}",
      "posts/#{post.id}/edit"
    ]

    routes_array.each do |route|
      visit route

      within("#navbar") do
        expect(page). to have_link("Posts", href: posts_path)
        expect(page). to have_link("Users", href: users_path)
      end
    end
  end
end
