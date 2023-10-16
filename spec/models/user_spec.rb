require 'rails_helper'

RSpec.describe User, type: :model do
  describe "#name" do
    it "returns the user's first name and last name combined" do
      user = User.create(first_name: 'Will', last_name: 'Ramos', birthdate: "1993")
      expect(user.name).to eq("Will Ramos")
    end
  end
end
