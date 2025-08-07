require 'rails_helper'

RSpec.describe "Turbo Path Configurations", type: :request do
  describe "GET /turbo/ios_path_configuration" do
    it "returns iOS path configuration JSON" do
      get "/turbo/ios_path_configuration"
      
      expect(response).to have_http_status(:success)
      expect(response.content_type).to match(/application\/json/)
      
      json = JSON.parse(response.body)
      expect(json).to have_key('settings')
      expect(json).to have_key('rules')
      expect(json['rules']).to be_an(Array)
    end
    
    it "includes iOS-specific properties" do
      get "/turbo/ios_path_configuration"
      
      json = JSON.parse(response.body)
      rules = json['rules']
      
      # Check for tab bar items with SF Symbols
      tab_rules = rules.select { |r| r['properties']['tab_bar_item'].present? }
      expect(tab_rules).not_to be_empty
      
      tab_rules.each do |rule|
        tab_item = rule['properties']['tab_bar_item']
        expect(tab_item).to have_key('title')
        expect(tab_item).to have_key('image')
        expect(tab_item['image']).to match(/\w+\.fill/)  # SF Symbol naming
      end
    end
    
    it "configures modal presentation for forms" do
      get "/turbo/ios_path_configuration"
      
      json = JSON.parse(response.body)
      rules = json['rules']
      
      modal_rules = rules.select { |r| r['properties']['presentation'] == 'modal' }
      expect(modal_rules).not_to be_empty
      
      # Check that form paths are configured as modals
      form_patterns = ['/posts/new', '/users/new', '/families/new']
      modal_patterns = modal_rules.flat_map { |r| r['patterns'] }
      
      form_patterns.each do |pattern|
        expect(modal_patterns.any? { |p| p.include?(pattern.split('/').last) }).to be true
      end
    end
  end
  
  describe "GET /turbo/android_path_configuration" do
    it "returns Android path configuration JSON" do
      get "/turbo/android_path_configuration"
      
      expect(response).to have_http_status(:success)
      expect(response.content_type).to match(/application\/json/)
      
      json = JSON.parse(response.body)
      expect(json).to have_key('settings')
      expect(json).to have_key('rules')
    end
    
    it "includes Android-specific properties" do
      get "/turbo/android_path_configuration"
      
      json = JSON.parse(response.body)
      rules = json['rules']
      
      # Check for bottom navigation items
      nav_rules = rules.select { |r| r['properties']['bottom_navigation_item'].present? }
      expect(nav_rules).not_to be_empty
      
      nav_rules.each do |rule|
        nav_item = rule['properties']['bottom_navigation_item']
        expect(nav_item).to have_key('title')
        expect(nav_item).to have_key('icon')
        expect(nav_item['icon']).to match(/^ic_/)  # Android icon naming
      end
    end
    
    it "includes toolbar configuration" do
      get "/turbo/android_path_configuration"
      
      json = JSON.parse(response.body)
      rules = json['rules']
      
      toolbar_rules = rules.select { |r| r['properties'].has_key?('toolbar_enabled') }
      expect(toolbar_rules).not_to be_empty
    end
  end
  
  describe "Path configuration error handling" do
    it "returns default configuration when file is missing" do
      allow(File).to receive(:exist?).and_return(false)
      
      get "/turbo/ios_path_configuration"
      
      expect(response).to have_http_status(:success)
      
      json = JSON.parse(response.body)
      expect(json['rules']).to be_an(Array)
      expect(json['rules'].first['patterns']).to include('.*')
    end
  end
end