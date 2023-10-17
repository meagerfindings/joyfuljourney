require 'rails_helper'
require 'random/formatter'

RSpec.describe User, type: :model do
  let(:user) { User.create(first_name: 'Will', last_name: 'Ramos', birthdate: "1993") }

  describe "#name" do
    it "returns the user's first name and last name combined" do
      expect(user.name).to eq("Will Ramos")
    end
  end

  describe "#post_count" do
    it "returns the number of the user's posts" do
      random_number = Random.new.random_number(10)
      random_number.times do |index|
        user.post.create(title: index, body: "I see my days unfold, under the impossible")
      end

      expect(user.post_count).to eq(random_number)
    end
  end
end
