require 'rails_helper'

RSpec.feature "Mobile Navigation", type: :feature do
  let(:user) { create(:user, username: 'mobileuser', password: 'password123', claimed: true) }
  
  context "as a Turbo Native iOS app" do
    before do
      page.driver.header('User-Agent', 'Turbo Native iOS')
    end
    
    scenario "uses mobile layout variant" do
      visit root_path
      
      # Should not show web navigation bar
      expect(page).not_to have_css('.navbar')
      
      # Should have native-specific classes
      expect(page).to have_css('body.turbo-native')
      
      # Should have bridge component placeholders
      expect(page).to have_css('#bridge-components')
      expect(page).to have_css('[data-bridge-component="menu"]')
      expect(page).to have_css('[data-bridge-component="form"]')
    end
    
    scenario "returns JSON for login" do
      page.driver.post('/login', {
        username: user.username,
        password: 'password123'
      })
      
      response = JSON.parse(page.body)
      expect(response).to have_key('token')
      expect(response['user']['username']).to eq(user.username)
    end
    
    scenario "includes current user data in meta tags when logged in" do
      login_as(user)
      visit root_path
      
      expect(page).to have_css('meta[name="current-user-data"]', visible: false)
      
      meta_content = page.find('meta[name="current-user-data"]', visible: false)['content']
      user_data = JSON.parse(meta_content)
      expect(user_data['id']).to eq(user.id)
    end
  end
  
  context "as a Turbo Native Android app" do
    before do
      page.driver.header('User-Agent', 'Turbo Native Android')
    end
    
    scenario "uses mobile layout variant" do
      visit root_path
      
      expect(page).not_to have_css('.navbar')
      expect(page).to have_css('body.turbo-native')
      expect(page).to have_css('#bridge-components')
    end
    
    scenario "handles authentication with JSON response" do
      page.driver.post('/login', {
        username: user.username,
        password: 'password123'
      })
      
      response = JSON.parse(page.body)
      expect(response).to have_key('token')
      expect(response['user']['id']).to eq(user.id)
    end
  end
  
  context "as a web browser" do
    before do
      page.driver.header('User-Agent', 'Mozilla/5.0 Chrome/91.0')
    end
    
    scenario "uses standard web layout" do
      visit root_path
      
      # Should show regular navigation for non-root pages
      visit posts_path
      expect(page).to have_css('.navbar') if page.current_path != '/'
      
      # Should not have native-specific elements
      expect(page).not_to have_css('body.turbo-native')
    end
    
    scenario "uses standard form-based login" do
      visit login_path
      
      fill_in 'Username', with: user.username
      fill_in 'Password', with: 'password123'
      click_button 'Login'
      
      expect(page).to have_current_path(root_path)
      expect(page).to have_content("Welcome, #{user.name}")
    end
  end
  
  describe "Bridge component rendering" do
    context "in native app" do
      before do
        page.driver.header('User-Agent', 'Turbo Native iOS')
        login_as(user)
      end
      
      scenario "flash messages have bridge component data attribute" do
        visit new_post_path
        
        fill_in 'Title', with: 'Test Post'
        fill_in 'Body', with: 'This is a test post body'
        click_button 'Create Post'
        
        expect(page).to have_css('[data-bridge-component="flash"]')
      end
      
      scenario "camera bridge replaces file inputs for images" do
        visit new_post_path
        
        # In a real native app, file inputs would be hidden
        # and replaced with native camera buttons
        expect(page).to have_css('input[type="file"][accept*="image"]', visible: :hidden)
      end
    end
  end
  
  private
  
  def login_as(user)
    visit login_path
    fill_in 'Username', with: user.username
    fill_in 'Password', with: 'password123'
    click_button 'Login'
  end
end