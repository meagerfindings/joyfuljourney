# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Authorization', type: :controller do
  let(:default_user) { create(:claimed_user, role: :default) }
  let(:manager_user) { create(:claimed_user, role: :manager) }
  let(:admin_user) { create(:claimed_user, role: :admin) }
  let(:other_user) { create(:claimed_user, role: :default) }

  describe UsersController do
    controller(UsersController) {}

    describe 'authorization for user actions' do
      let(:target_user) { create(:user) }

      context 'when not logged in' do
        it 'redirects to login for protected actions' do
          get :show, params: { id: target_user.id }
          expect(response).to redirect_to(login_path)
          expect(flash[:error]).to eq('You must be logged in to access this page.')
        end

        it 'allows access to new and create' do
          get :new
          expect(response).to be_successful
        end
      end

      context 'when logged in as default user' do
        before { session[:user_id] = default_user.id }

        it 'allows access to own profile' do
          get :show, params: { id: default_user.id }
          expect(response).to be_successful
        end

        it "denies access to other user's profile" do
          get :show, params: { id: other_user.id }
          expect(response).to redirect_to(root_path)
          expect(flash[:error]).to eq('You can only access your own profile.')
        end

        it 'denies access to user index' do
          get :index
          expect(response).to redirect_to(root_path)
          expect(flash[:error]).to eq('You must be a manager or admin to access this page.')
        end

        it 'denies destroy action' do
          delete :destroy, params: { id: target_user.id }
          expect(response).to redirect_to(root_path)
          expect(flash[:error]).to eq('You must be a manager or admin to access this page.')
        end
      end

      context 'when logged in as manager' do
        before { session[:user_id] = manager_user.id }

        it 'allows access to user index' do
          get :index
          expect(response).to be_successful
        end

        it "allows access to any user's profile" do
          get :show, params: { id: other_user.id }
          expect(response).to be_successful
        end

        it 'allows destroy action' do
          delete :destroy, params: { id: target_user.id }
          expect(response).to redirect_to(users_path)
        end
      end

      context 'when logged in as admin' do
        before { session[:user_id] = admin_user.id }

        it 'allows access to user index' do
          get :index
          expect(response).to be_successful
        end

        it "allows access to any user's profile" do
          get :show, params: { id: other_user.id }
          expect(response).to be_successful
        end

        it 'allows destroy action' do
          delete :destroy, params: { id: target_user.id }
          expect(response).to redirect_to(users_path)
        end
      end
    end
  end

  describe PostsController do
    controller(PostsController) {}

    let(:user_post) { create(:post, user: default_user) }
    let(:other_post) { create(:post, user: other_user) }

    describe 'authorization for post actions' do
      context 'when not logged in' do
        it 'allows access to index and show' do
          get :index
          expect(response).to be_successful

          get :show, params: { id: user_post.id }
          expect(response).to be_successful
        end

        it 'redirects to login for protected actions' do
          get :new
          expect(response).to redirect_to(login_path)
          expect(flash[:error]).to eq('You must be logged in to access this page.')
        end
      end

      context 'when logged in as default user' do
        before { session[:user_id] = default_user.id }

        it 'allows creating posts' do
          get :new
          expect(response).to be_successful
        end

        it 'allows editing own posts' do
          get :edit, params: { id: user_post.id }
          expect(response).to be_successful
        end

        it "denies editing other user's posts" do
          get :edit, params: { id: other_post.id }
          expect(response).to redirect_to(root_path)
          expect(flash[:error]).to eq('You can only access your own posts.')
        end

        it 'allows deleting own posts' do
          delete :destroy, params: { id: user_post.id }
          expect(response).to redirect_to(posts_path)
        end

        it "denies deleting other user's posts" do
          delete :destroy, params: { id: other_post.id }
          expect(response).to redirect_to(root_path)
          expect(flash[:error]).to eq('You can only access your own posts.')
        end
      end

      context 'when logged in as manager' do
        before { session[:user_id] = manager_user.id }

        it 'allows editing any post' do
          get :edit, params: { id: other_post.id }
          expect(response).to be_successful
        end

        it 'allows deleting any post' do
          delete :destroy, params: { id: other_post.id }
          expect(response).to redirect_to(posts_path)
        end
      end

      context 'when logged in as admin' do
        before { session[:user_id] = admin_user.id }

        it 'allows editing any post' do
          get :edit, params: { id: other_post.id }
          expect(response).to be_successful
        end

        it 'allows deleting any post' do
          delete :destroy, params: { id: other_post.id }
          expect(response).to redirect_to(posts_path)
        end
      end
    end
  end
end
