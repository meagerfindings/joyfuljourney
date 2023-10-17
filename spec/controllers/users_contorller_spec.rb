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
end
