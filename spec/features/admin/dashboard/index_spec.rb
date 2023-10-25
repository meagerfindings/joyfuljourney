require "rails_helper"

describe "Admin can email users" do
  describe "As an admin" do
    it "can load admin dashboard index" do
      admin = create(:claimed_user, role: 2)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

      visit "/admin/dashboard"
      expect(page).to have_content("Admin Dashboard")
    end
  end

  describe "as manager" do
    it 'does not allow manager to load admin dashboard index' do
      manager = create(:claimed_user, role: 1)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(manager)

      visit "/admin/dashboard"

      expect(page).to_not have_content("Admin Dashboard")
      expect(page).to have_content("The page you were looking for doesn't exist.")
    end
  end

  describe "as default user" do
    it 'does not allow default user to load admin dashboard index' do
      default_user = create(:claimed_user)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(default_user)

      visit "/admin/dashboard"

      expect(page).to_not have_content("Admin Dashboard")
      expect(page).to have_content("The page you were looking for doesn't exist.")
    end
  end
end
