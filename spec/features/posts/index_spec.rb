require 'rails_helper'

RSpec.describe "Posts Index Page", type: :feature do
  it "shows all posts" do
    user_1 = User.create(first_name: "Elon", last_name: "Musk", birthdate: "June 28, 1971")
    user_2 = User.create(first_name: "Sam", last_name: "Altman", birthdate: "April 22, 1985")

    post_1 = user_1.post.create(title: "Thoughts on Fear", body: "I feel fear quite strongly. It’s not as though I just have the absence of fear. I feel it quite strongly. But there are times when something is important enough, you believe in it enough, that you do it in spite of the fear. People shouldn’t think, ‘I feel fear about this, and therefore I shouldn’t do it.’ It’s normal to feel fear. There’d have to be something mentally wrong [with you] if you didn't feel fear. […] If you just accept the probabilities, then that diminishes fear.")

    post_2 = user_2.post.create(title: "Company", body: "No matter what you choose, build stuff and be around smart people.")

    visit 'posts'

    within("#post-#{post_1.id}") do
      expect(page).to have_content(post_1.title)
      expect(page).to have_content(post_1.body)
      expect(page).to have_link(post_1.title, href: post_path(post_1))
    end

    within("#post-#{post_2.id}") do
      expect(page).to have_content(post_2.title)
      expect(page).to have_content(post_2.body)
      expect(page).to have_link(post_2.title, href: post_path(post_2))
    end
  end
end
