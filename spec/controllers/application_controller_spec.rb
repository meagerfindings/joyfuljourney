require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: 'OK'
    end
  end
  
  describe "authentication" do
    let(:user) { create(:user, authentication_token: 'test_token_123') }
    
    context "with session authentication" do
      it "finds user by session" do
        session[:user_id] = user.id
        get :index
        
        expect(controller.current_user).to eq(user)
      end
    end
    
    context "with token authentication" do
      it "finds user by authorization header" do
        request.headers['Authorization'] = "Bearer #{user.authentication_token}"
        get :index
        
        expect(controller.current_user).to eq(user)
      end
      
      it "handles missing token gracefully" do
        request.headers['Authorization'] = "Bearer invalid_token"
        get :index
        
        expect(controller.current_user).to be_nil
      end
      
      it "handles malformed authorization header" do
        request.headers['Authorization'] = "InvalidFormat"
        get :index
        
        expect(controller.current_user).to be_nil
      end
    end
    
    context "with both session and token" do
      let(:session_user) { create(:user) }
      let(:token_user) { create(:user, authentication_token: 'different_token') }
      
      it "prefers session over token" do
        session[:user_id] = session_user.id
        request.headers['Authorization'] = "Bearer #{token_user.authentication_token}"
        get :index
        
        expect(controller.current_user).to eq(session_user)
      end
    end
  end
  
  describe "native app detection" do
    it "detects Turbo Native app" do
      request.user_agent = "Mozilla/5.0 Turbo Native"
      get :index
      
      expect(controller.turbo_native_app?).to be true
    end
    
    it "detects iOS app specifically" do
      request.user_agent = "Turbo Native iOS"
      get :index
      
      expect(controller.turbo_native_ios?).to be true
      expect(controller.turbo_native_android?).to be false
    end
    
    it "detects Android app specifically" do
      request.user_agent = "Turbo Native Android"
      get :index
      
      expect(controller.turbo_native_android?).to be true
      expect(controller.turbo_native_ios?).to be false
    end
    
    it "returns false for regular browsers" do
      request.user_agent = "Mozilla/5.0 Chrome/91.0"
      get :index
      
      expect(controller.turbo_native_app?).to be false
      expect(controller.turbo_native_ios?).to be false
      expect(controller.turbo_native_android?).to be false
    end
  end
  
  describe "#set_current_user_for_javascript" do
    context "with logged in user" do
      let(:user) { create(:user) }
      
      before do
        session[:user_id] = user.id
      end
      
      it "sets current_user_json instance variable" do
        get :index
        
        expect(assigns(:current_user_json)).to be_present
        
        data = JSON.parse(assigns(:current_user_json))
        expect(data['id']).to eq(user.id)
      end
    end
    
    context "without logged in user" do
      it "does not set current_user_json" do
        get :index
        
        expect(assigns(:current_user_json)).to be_nil
      end
    end
  end
end