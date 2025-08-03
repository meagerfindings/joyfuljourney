require 'rails_helper'

RSpec.describe Milestone, type: :model do
  let(:user) { create(:user) }
  let(:family) { create(:family) }
  let(:post) { create(:post, user: user) }

  describe 'validations' do
    it 'validates presence of required fields' do
      milestone = Milestone.new
      expect(milestone).not_to be_valid
      expect(milestone.errors[:title]).to include("can't be blank")
      expect(milestone.errors[:milestone_date]).to include("can't be blank")
      expect(milestone.errors[:milestone_type]).to include("can't be blank")
      expect(milestone.errors[:created_by_user_id]).to include("can't be blank")
    end

    it 'validates milestone_type inclusion' do
      milestone = build(:milestone, milestone_type: 'invalid_type')
      expect(milestone).not_to be_valid
      expect(milestone.errors[:milestone_type]).to include('is not included in the list')
    end

    it 'accepts valid milestone types' do
      Milestone::MILESTONE_TYPES.each do |type|
        milestone = build(:milestone, milestone_type: type)
        expect(milestone).to be_valid
      end
    end
  end

  describe 'associations' do
    it 'belongs to milestoneable polymorphically' do
      user_milestone = create(:milestone, milestoneable: user)
      expect(user_milestone.milestoneable).to eq(user)
      expect(user_milestone.milestoneable_type).to eq('User')

      family_milestone = create(:milestone, milestoneable: family)
      expect(family_milestone.milestoneable).to eq(family)
      expect(family_milestone.milestoneable_type).to eq('Family')

      post_milestone = create(:milestone, milestoneable: post)
      expect(post_milestone.milestoneable).to eq(post)
      expect(post_milestone.milestoneable_type).to eq('Post')
    end

    it 'belongs to created_by_user' do
      milestone = create(:milestone, created_by_user: user)
      expect(milestone.created_by_user).to eq(user)
    end
  end

  describe 'scopes' do
    let!(:user_milestone) { create(:milestone, milestoneable: user, is_private: false) }
    let!(:family_milestone) { create(:milestone, milestoneable: family, is_private: true) }
    let!(:post_milestone) { create(:milestone, milestoneable: post) }

    it 'filters by milestoneable type' do
      expect(Milestone.for_user(user)).to include(user_milestone)
      expect(Milestone.for_family(family)).to include(family_milestone)
      expect(Milestone.for_post(post)).to include(post_milestone)
    end

    it 'filters by privacy' do
      expect(Milestone.public_milestones).to include(user_milestone)
      expect(Milestone.public_milestones).not_to include(family_milestone)
      expect(Milestone.private_milestones).to include(family_milestone)
      expect(Milestone.private_milestones).not_to include(user_milestone)
    end
  end

  describe '#milestone_type_display' do
    it 'humanizes the milestone type' do
      milestone = build(:milestone, milestone_type: 'first_steps')
      expect(milestone.milestone_type_display).to eq('First steps')
    end
  end

  describe '#visible_to?' do
    let(:creator) { create(:user) }
    let(:family_member) { create(:user, family: creator.family) }
    let(:other_user) { create(:user) }

    context 'for public milestones' do
      let(:milestone) { create(:milestone, milestoneable: creator, created_by_user: creator, is_private: false) }

      it 'is visible to anyone' do
        expect(milestone.visible_to?(creator)).to be true
        expect(milestone.visible_to?(family_member)).to be true
        expect(milestone.visible_to?(other_user)).to be true
      end
    end

    context 'for private user milestones' do
      let(:milestone) { create(:milestone, milestoneable: creator, created_by_user: creator, is_private: true) }

      it 'is visible to the user themselves' do
        expect(milestone.visible_to?(creator)).to be true
      end

      it 'is visible to family members' do
        expect(milestone.visible_to?(family_member)).to be true
      end

      it 'is not visible to non-family members' do
        expect(milestone.visible_to?(other_user)).to be false
      end
    end

    context 'for private family milestones' do
      let(:family) { creator.family }
      let(:milestone) { create(:milestone, milestoneable: family, created_by_user: creator, is_private: true) }

      it 'is visible to family members' do
        expect(milestone.visible_to?(creator)).to be true
        expect(milestone.visible_to?(family_member)).to be true
      end

      it 'is not visible to non-family members' do
        expect(milestone.visible_to?(other_user)).to be false
      end
    end
  end
end