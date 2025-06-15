require 'rails_helper'

RSpec.describe Post, type: :model do
  subject { build(:post) }

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:body) }
    it { should validate_length_of(:body).is_at_least(10) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'scopes' do
    let(:family) { create(:family) }
    let(:user_in_family) { create(:claimed_user, family: family) }
    let(:user_outside_family) { create(:claimed_user) }
    
    let!(:public_post_in_family) { create(:post, user: user_in_family, private: false) }
    let!(:private_post_in_family) { create(:post, :private, user: user_in_family) }
    let!(:public_post_outside_family) { create(:post, user: user_outside_family, private: false) }

    describe '.visible_to_family' do
      it 'returns only public posts from family members' do
        visible_posts = Post.visible_to_family(family)
        
        expect(visible_posts).to include(public_post_in_family)
        expect(visible_posts).not_to include(private_post_in_family)
        expect(visible_posts).not_to include(public_post_outside_family)
      end
    end

    describe '.private_posts' do
      it 'returns only private posts' do
        private_posts = Post.private_posts
        
        expect(private_posts).to include(private_post_in_family)
        expect(private_posts).not_to include(public_post_in_family)
        expect(private_posts).not_to include(public_post_outside_family)
      end
    end

    describe '.public_posts' do
      it 'returns only public posts' do
        public_posts = Post.public_posts
        
        expect(public_posts).to include(public_post_in_family)
        expect(public_posts).to include(public_post_outside_family)
        expect(public_posts).not_to include(private_post_in_family)
      end
    end
  end

  describe 'privacy' do
    it 'defaults to public' do
      post = create(:post)
      expect(post.private?).to be false
    end

    it 'can be marked as private' do
      post = create(:post, :private)
      expect(post.private?).to be true
    end
  end
end