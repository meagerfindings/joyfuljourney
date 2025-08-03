require 'rails_helper'
require 'random/formatter'

RSpec.describe User, type: :model do
  let(:user) { create(:user) }

  describe 'validations' do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }

    context 'when unclaimed' do
      it { should validate_uniqueness_of(:username).case_insensitive }
    end

    context 'when claimed' do
      subject { create(:claimed_user) }

      it 'should validate presence of username' do
        is_expected.to validate_presence_of(:username)
      end

      it { should validate_uniqueness_of(:username).case_insensitive }
      it { should validate_presence_of(:password) }
    end
  end
  describe '#name' do
    it "returns the user's first name and last name combined" do
      expect(user.name).to eq('Will Ramos')
    end
  end

  describe '#post_count' do
    it "returns the number of the user's posts" do
      random_number = Random.new.random_number(10)
      random_number.times do |index|
        user.posts.create(title: index, body: 'I see my days unfold, under the impossible')
      end

      expect(user.post_count).to eq(random_number)
    end
  end

  describe '#set_random_password' do
    context 'with an unclaimed user' do
      it 'sets a random password on create' do
        unclaimed_user = create(:user, password: nil)
        expect(unclaimed_user.password).to be_present
      end
    end
  end

  describe '#set_random_username' do
    context 'with an unclaimed user' do
      it 'sets a random username on create' do
        unclaimed_user = create(:user, username: nil)
        expect(unclaimed_user.username).to be_present
      end
    end
  end

  describe '#downcase_username' do
    let(:username) { 'SLEEPtoken' }
    context 'with an unclaimed user' do
      it 'downcases username prior to save' do
        unclaimed_user = create(:user, username:)
        expect(unclaimed_user.username).to eq(username.downcase)
      end
    end

    context 'with a claimed user' do
      it 'downcases username prior to save' do
        claimed_user = create(:claimed_user, username:)
        expect(claimed_user.username).to eq(username.downcase)
      end
    end
  end
end
