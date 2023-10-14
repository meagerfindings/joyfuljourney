# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  describe 'Get Index' do
    it 'renders index' do
      get :index
      expect(response).to render_template('index')
    end
  end

  describe 'Create' do
    it 'creates a new Post' do
      post_params = { post: { title: 'johnny five', body: 'is alive! and likes peppers too' } }

      put :create, params: post_params
      expect(response).to redirect_to post_path({ id: Post.last })
    end

    it 'does not create without title' do
      post_params = { post: { body: 'is alive! and likes peppers too' } }

      put :create, params: post_params
      expect(response).to have_http_status(422)
    end

    it 'does not create without body' do
      post_params = { post: { title: 'Branches Tangled' } }

      put :create, params: post_params
      expect(response).to have_http_status(422)
    end
  end

  describe 'Update' do
    xit 'updates the post' do
      # let post
    end
    xit 'returns an error'
  end
end