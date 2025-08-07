require 'rails_helper'

RSpec.describe "Api::V1::Sessions", type: :request do
  let(:user) { create(:user, username: 'testuser', password: 'password123', claimed: true) }
  
  describe "POST /api/v1/login" do
    context "with valid credentials" do
      it "returns authentication token and user data" do
        post "/api/v1/login", params: {
          username: user.username,
          password: 'password123'
        }
        
        expect(response).to have_http_status(:success)
        
        json = JSON.parse(response.body)
        expect(json['token']).to be_present
        expect(json['user']['id']).to eq(user.id)
        expect(json['user']['username']).to eq(user.username)
        expect(json['user']['name']).to eq(user.name)
      end
      
      it "ensures user has authentication token after login" do
        post "/api/v1/login", params: {
          username: user.username,
          password: 'password123'
        }
        
        expect(user.reload.authentication_token).to be_present
      end
    end
    
    context "with invalid credentials" do
      it "returns unauthorized status" do
        post "/api/v1/login", params: {
          username: user.username,
          password: 'wrongpassword'
        }
        
        expect(response).to have_http_status(:unauthorized)
        
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Invalid username or password')
      end
      
      it "does not generate authentication token" do
        expect {
          post "/api/v1/login", params: {
            username: user.username,
            password: 'wrongpassword'
          }
        }.not_to change { user.reload.authentication_token }
      end
    end
    
    context "with non-existent user" do
      it "returns unauthorized status" do
        post "/api/v1/login", params: {
          username: 'nonexistent',
          password: 'password123'
        }
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
  
  describe "DELETE /api/v1/logout" do
    let(:authenticated_user) { create(:user, authentication_token: 'test_token') }
    
    context "with valid authentication token" do
      it "clears the authentication token" do
        delete "/api/v1/logout", headers: {
          'Authorization' => "Bearer #{authenticated_user.authentication_token}"
        }
        
        expect(response).to have_http_status(:no_content)
        expect(authenticated_user.reload.authentication_token).to be_nil
      end
    end
    
    context "without authentication token" do
      it "returns unauthorized status" do
        delete "/api/v1/logout"
        
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end