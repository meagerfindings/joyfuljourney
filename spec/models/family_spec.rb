require 'rails_helper'

RSpec.describe Family, type: :model do
  subject { build(:family) }

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'associations' do
    it { should have_many(:users).dependent(:destroy) }
    it { should have_many(:posts).through(:users) }
  end

  describe 'attributes' do
    it 'has a name' do
      family = create(:family, name: 'Smith Family')
      expect(family.name).to eq('Smith Family')
    end
  end

  describe 'family relationships' do
    let(:family) { create(:family) }
    let(:user1) { create(:claimed_user, family: family) }
    let(:user2) { create(:claimed_user, family: family) }

    it 'can have multiple users' do
      expect(family.users).to include(user1, user2)
    end

    it 'provides access to all family posts through users' do
      post1 = create(:post, user: user1)
      post2 = create(:post, user: user2)
      
      expect(family.posts).to include(post1, post2)
    end
  end
end