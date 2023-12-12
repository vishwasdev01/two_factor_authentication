# spec/controllers/users_controller_spec.rb
require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe 'POST #sign_up' do
    context 'with valid parameters' do
      it 'creates a new user account and sends a welcome email' do
        post :sign_up, params: { user: { email: 'test@example.com', password: 'password', password_confirmation: 'password' }}
        expect(response).to have_http_status(:success)
        expect(response.body).to include('Account successfully created')
      end
    end

    context 'with invalid parameters' do
      it 'fails to create a new user account' do
        post :sign_up, params: { user: { email: 'test@example.com', password: 'password', password_confirmation: 'wrong_password' }}
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('error')
      end
    end
  end

  describe 'POST #login' do
    let(:user) { FactoryBot.create(:user, email: 'test@example.com', password: 'password' ,password_confirmation: 'password') }

    context 'with valid credentials and 2FA disabled' do
      it 'logs in successfully without 2FA' do
        user.update(enable_2fa: true)
        post :login, params: { email: user.email, password: 'password' }
        expect(response).to have_http_status(:success)
        expect(response.body).to include('You have logged in successfully')
      end
    end

    context 'with valid credentials and 2FA enabled' do
      it 'sends an OTP and requires 2FA confirmation' do
        post :login, params: { email: user.email, password: 'password' } 
        expect(response).to have_http_status(:success)
        expect(response.body).to include('Otp send successfully')
      end
    end

    context 'with invalid credentials' do
      it 'fails to log in with incorrect email or password' do
        post :login, params:  { email: 'wrong@example.com', password: 'wrong_password' }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('Invalid Email or Password')
      end
    end
  end

  describe 'POST #two_factor_auth' do
    let(:user) { FactoryBot.create(:user, email: 'test@example.com', password: 'password' ,password_confirmation: 'password') }
    
    context 'with valid OTP' do
      it 'logs in successfully with 2FA' do
        @token = JsonWebToken.encode(user: user.id)
        request.headers['token'] = @token
        post :two_factor_auth, params: { otp: '123456' }
        expect(response).to have_http_status(:success)
        expect(response.body).to include('You have successfully logged in')
      end
    end

    context 'with invalid OTP' do
      it 'fails to log in with incorrect OTP' do
        @token = JsonWebToken.encode(user: user.id)
        request.headers['token'] = @token
        post :two_factor_auth, params: { otp: '654321' }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('Otp is not valid')
      end
    end
  end

  describe 'post #enable_2fa' do
    let(:user) { FactoryBot.create(:user, email: 'test@example.com', password: 'password' ,password_confirmation: 'password') }
    

    context 'with valid parameters' do
      it 'updates the user\'s 2FA status successfully' do
        @token = JsonWebToken.encode(user: user.id)
        request.headers['token'] = @token
        post :enable_2fa, params: { enable_2fa: true}
        expect(response).to have_http_status(:success)
        expect(response.body).to include('Your 2FA request updated successfully')
      end
    end
  end

  describe 'post #update_password' do
    let(:user) { FactoryBot.create(:user, email: 'test@example.com', password: 'password' ,password_confirmation: 'password') }
    context 'with valid parameters' do
      it 'updates the user\'s password successfully' do
        @token = JsonWebToken.encode(user: user.id)
        request.headers['token'] = @token
        post :update_password, params: { password: 'password', new_password: 'new_password' }
        expect(response).to have_http_status(:success)
        expect(response.body).to include('Password updated successfully')
      end
    end

    context 'with invalid parameters' do
      it 'fails to update the password with incorrect old password' do
        @token = JsonWebToken.encode(user: user.id)
        request.headers['token'] = @token
        post :update_password, params: { password: 'wrong_password', new_password: 'new_password' }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('Please provide correct password')
      end
    end
  end
end
