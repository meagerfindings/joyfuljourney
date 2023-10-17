# frozen_string_literal: true
require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) { User.create(first_name: "Amos", last_name: "Burton", birthdate: "July 4, 3315") }

  describe 'GET #index' do
    it 'renders index' do
      get :index
      expect(response).to be_successful
      expect(response).to render_template(:index)
    end
  end

  describe "GET #show" do
    it "renders show" do
      get :show, params: { id: user.to_param }
      expect(response).to be_successful
      expect(response).to render_template(:show)
    end
  end

  describe "GET #new" do
    it "renders new" do
      get :new
      expect(response).to be_successful
      expect(response).to render_template(:new)
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
      get :edit, params: { id: user.to_param }
      expect(response).to be_successful
      expect(response).to render_template(:edit)
    end
  end

  describe "PUT #update" do
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

  describe "DELETE #destroy" do
    before do
      user # forces the initial user to be loaded
      User.create(first_name: "First", last_name: "Last")
    end

    it "destroys the requested user" do
      prior_user_count = User.all.count

      delete :destroy, params: { id: user.to_param }

      after_user_count = User.all.count
      expect(after_user_count).to eq(prior_user_count - 1)
    end

    it "redirects to the users list" do
      delete :destroy, params: { id: user.to_param }
      expect(response).to redirect_to(users_path)
    end
  end
end
