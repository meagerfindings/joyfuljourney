require 'rails_helper'

RSpec.describe 'Posts Index Page', type: :feature do
  let(:user_1) { User.create(first_name: 'Elon', last_name: 'Musk', birthdate: 'June 28, 1971') }
  let(:user_2) { User.create(first_name: 'Sam', last_name: 'Altman', birthdate: 'April 22, 1985') }

  before(:each) do
    DatabaseCleaner.clean_with(:truncation)
  end

  it 'shows all posts' do
    post_1 = user_1.post.create(title: 'Thoughts on Fear',
                                body: "I feel fear quite strongly. It’s not as though I just have the absence of fear. I feel it quite strongly. But there are times when something is important enough, you believe in it enough, that you do it in spite of the fear. People shouldn’t think, ‘I feel fear about this, and therefore I shouldn’t do it.’ It’s normal to feel fear. There’d have to be something mentally wrong [with you] if you didn't feel fear. […] If you just accept the probabilities, then that diminishes fear.")

    post_2 = user_2.post.create(title: 'Company',
                                body: 'No matter what you choose, build stuff and be around smart people.')

    visit 'posts'

    within('h1') do
      expect(page).to have_content('All Posts')
    end

    within("#post-#{post_1.id}") do
      expect(page).to have_content(post_1.title)
      expect(page).to have_content(post_1.body)
      expect(page).to have_link(post_1.title, href: post_path(post_1))
      expect(page).to have_content("by: #{user_1.name}")
    end

    within("#post-#{post_2.id}") do
      expect(page).to have_content(post_2.title)
      expect(page).to have_content(post_2.body)
      expect(page).to have_link(post_2.title, href: post_path(post_2))
      expect(page).to have_content("by: #{user_2.name}")
    end
  end

  it 'has a link to create new posts' do
    visit 'posts'
    expect(page).to have_link('New Memory', href: new_post_path)
    click_link 'New Memory'
  end

  describe "when given a specific user's post index" do
    let(:user_3) { User.create(first_name: 'Mark', last_name: 'Rippetoe', birthdate: 'May 5, 1910') }

    it 'only displays all of the posts from that user' do
      post_1 = user_1.post.create(title: 'Coral', body: 'Coral, what happened to Lori?')
      post_2 = user_3.post.create(title: 'Squat', body: 'Do your Fahves. Do em!')
      post_3 = user_1.post.create(title: 'Fear', body: 'I feel no fear... but I do...')
      post_4 = user_1.post.create(title: 'Tesla', body: 'built tough, no... like a rock... no...')

      visit "users/#{user_1.id}/posts"

      within('h1') do
        expect(page).to have_content("#{user_1.name}'s Posts")
      end

      within("#post-#{post_1.id}") do
        expect(page).to have_content(post_1.title)
        expect(page).to have_content(post_1.body)
        expect(page).to have_link(post_1.title, href: post_path(post_1))
        expect(page).to have_content("by: #{user_1.name}")
      end

      expect(page).to_not have_content(post_2.title)
      expect(page).to_not have_content(post_2.body)
      expect(page).to_not have_link(post_2.title, href: post_path(post_2))
      expect(page).to_not have_content("by: #{user_3.name}")

      within("#post-#{post_3.id}") do
        expect(page).to have_content(post_3.title)
        expect(page).to have_content(post_3.body)
        expect(page).to have_link(post_3.title, href: post_path(post_3))
        expect(page).to have_content("by: #{user_1.name}")
      end

      within("#post-#{post_4.id}") do
        expect(page).to have_content(post_4.title)
        expect(page).to have_content(post_4.body)
        expect(page).to have_link(post_4.title, href: post_path(post_4))
        expect(page).to have_content("by: #{user_1.name}")
      end
    end
  end
end
