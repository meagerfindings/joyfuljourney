require 'rails_helper'

RSpec.describe "TurboNativeHelpers", type: :helper do
  describe "#turbo_native_app?" do
    it "returns true for Turbo Native user agent" do
      allow(request).to receive(:user_agent).and_return("Mozilla/5.0 Turbo Native iOS")
      expect(helper.turbo_native_app?).to be true
    end
    
    it "returns false for regular browser user agent" do
      allow(request).to receive(:user_agent).and_return("Mozilla/5.0 Chrome/91.0")
      expect(helper.turbo_native_app?).to be false
    end
    
    it "handles nil user agent" do
      allow(request).to receive(:user_agent).and_return(nil)
      expect(helper.turbo_native_app?).to be false
    end
  end
  
  describe "#turbo_native_ios?" do
    it "returns true for iOS Turbo Native app" do
      allow(request).to receive(:user_agent).and_return("Turbo Native iOS/1.0")
      expect(helper.turbo_native_ios?).to be true
    end
    
    it "returns false for Android Turbo Native app" do
      allow(request).to receive(:user_agent).and_return("Turbo Native Android/1.0")
      expect(helper.turbo_native_ios?).to be false
    end
    
    it "returns false for non-native app" do
      allow(request).to receive(:user_agent).and_return("Safari/604.1")
      expect(helper.turbo_native_ios?).to be false
    end
  end
  
  describe "#turbo_native_android?" do
    it "returns true for Android Turbo Native app" do
      allow(request).to receive(:user_agent).and_return("Turbo Native Android/1.0")
      expect(helper.turbo_native_android?).to be true
    end
    
    it "returns false for iOS Turbo Native app" do
      allow(request).to receive(:user_agent).and_return("Turbo Native iOS/1.0")
      expect(helper.turbo_native_android?).to be false
    end
    
    it "returns false for non-native app" do
      allow(request).to receive(:user_agent).and_return("Chrome/91.0")
      expect(helper.turbo_native_android?).to be false
    end
  end
  
  describe "#current_user_json" do
    context "with logged in user" do
      let(:user) { create(:user, username: 'testuser', role: 'admin') }
      
      before do
        allow(helper).to receive(:current_user).and_return(user)
      end
      
      it "returns JSON string with user data" do
        json_str = helper.current_user_json
        expect(json_str).to be_a(String)
        
        data = JSON.parse(json_str)
        expect(data['id']).to eq(user.id)
        expect(data['username']).to eq(user.username)
        expect(data['role']).to eq(user.role)
        expect(data['name']).to eq(user.name)
      end
    end
    
    context "without logged in user" do
      before do
        allow(helper).to receive(:current_user).and_return(nil)
      end
      
      it "returns nil" do
        expect(helper.current_user_json).to be_nil
      end
    end
  end
end