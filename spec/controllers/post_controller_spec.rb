# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  let(:user) { User.create(first_name: 'Johny', last_name: 'Five') }
  let(:post_1) { user.posts.create(title: 'Live Please', body: 'No disassemble! Stephanie, no disassemble!') }

  describe 'Get Index' do
    it 'renders index' do
      get :index
      expect(response).to render_template('index')
    end
  end

  describe 'GET #show' do
    it 'renders show' do
      get :show, params: { id: post_1.to_param }
      expect(response).to be_successful
      expect(response).to render_template(:show)
    end
  end

  describe 'GET #new' do
    it 'renders new' do
      get :new
      expect(response).to be_successful
      expect(response).to render_template(:new)
    end
  end

  describe 'Create' do
    it 'creates a new Post' do
      post_params = { post: { title: 'johnny five', body: 'is alive! and likes peppers too', user_id: user.id } }

      put :create, params: post_params
      expect(response).to redirect_to post_path({ id: Post.last })
    end

    it 'does not create without title' do
      post_params = { post: { body: 'is alive! and likes peppers too', user_id: user.id } }

      put :create, params: post_params
      expect(response).to have_http_status(422)
    end

    it 'does not create without body' do
      post_params = { post: { title: 'Branches Tangled', user_id: user.id } }

      put :create, params: post_params
      expect(response).to have_http_status(422)
    end
  end
  describe 'GET #edit' do
    it 'renders edit' do
      get :edit, params: { id: post_1.to_param }
      expect(response).to be_successful
      expect(response).to render_template(:edit)
    end
  end

  describe 'PUT #update' do
    context 'with valid parameters' do
      let(:new_attributes) { { title: 'Modified' } }

      it 'updates the requested post' do
        put :update, params: { id: post_1.to_param, post: new_attributes }
        post_1.reload
        expect(post_1.title).to eq(new_attributes[:title])
      end

      it 'redirects to the post' do
        put :update, params: { id: post_1.to_param, post: new_attributes }
        expect(response).to redirect_to(post_1)
      end
    end

    context 'with invalid parameters' do
      it 'does not update the post' do
        put :update, params: { id: post_1.to_param, post: { title: '' } }
        expect(response).to have_http_status(422)
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
      post_1 # forces the initial post to load
    end

    it 'destroys the requested user' do
      prior_post_count = Post.all.count

      delete :destroy, params: { id: post_1.to_param }

      after_post_count = Post.all.count
      expect(after_post_count).to eq(prior_post_count - 1)
    end

    it 'redirects to the users list' do
      delete :destroy, params: { id: post_1.to_param }
      expect(response).to redirect_to(posts_path)
    end
  end
end
