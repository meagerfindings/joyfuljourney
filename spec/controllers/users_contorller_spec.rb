# frozen_string_literal: true
require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe 'GET #index' do
    it 'renders index' do
      get :index
      expect(response).to be_successful
      expect(response).to render_template(:index)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new user' do
        post :create, params: { user: { first_name: "Amos", last_name: "Burton", birthdate: "July 4, 3315" } }
        expect(response).to redirect_to user_path(id: User.last)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a user without first name' do
        post :create, params: { user: { last_name: "Burton", birthdate: "July 4, 3315" } }
        expect(response).to have_http_status(422)
        expect(response).to render_template(:new)
      end

      it 'does not create a user without last name' do
        post :create, params: { user: { first_name: "Amos", birthdate: "July 4, 3315" } }
        expect(response).to have_http_status(422)
        expect(response).to render_template(:new)
      end
    end
  end

  describe "GET #edit" do
    it "renders edit" do
      user = User.create(first_name: "Amos", last_name: "Burton", birthdate: "July 4, 3315")
      get :edit, params: { id: user.to_param }
      expect(response).to be_successful
      expect(response).to render_template(:edit)
    end
  end

  describe "PUT #update" do
    let(:user) { User.create(first_name: "Amos", last_name: "Burton", birthdate: "July 4, 3315") }

    context "with valid parameters" do
      let(:new_attributes) { { first_name: "Tim" } }

      it "updates the requested user" do
        put :update, params: { id: user.to_param, user: new_attributes }
        user.reload
        expect(user.first_name).to eq(new_attributes[:first_name])
      end

      it "redirects to the user" do
        put :update, params: { id: user.to_param, user: new_attributes }
        expect(response).to redirect_to(user)
      end
    end

    context "with invalid parameters" do
      it 'does not update the user' do
        put :update, params: { id: user.to_param, user: { first_name: '' } }
        expect(response).to have_http_status(422)
        expect(response).to render_template(:edit)
      end
    end
  end
end
