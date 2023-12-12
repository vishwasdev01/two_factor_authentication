require 'securerandom'
class UsersController < ApplicationController
  before_action :set_user, only: [:two_factor_auth, :enable_2fa, :update_password]

  def new
  end
  
  
  def create
    @user = User.new(user_params)
    if @user.save
      ConfirmationMailer.welcome_email(@user).deliver_now
      redirect_to login_path
    else
      flash[:error] = "Error- please try to create an account again."
      redirect_to new_user_path
    end
  end

  def show
  end
  
  def login
    @user = User.find_by(email: params[:email])
    if @user && @user.authenticate(params[:password])
      token = JsonWebToken.encode(user: @user.id)
      unless @user.enable_2fa 
        otp = @user.generate_otp
        @user.update(otp: otp)
        render json: {token: token,message: 'Otp send successfully'}
      else
        render json: {token: token,message: 'You have logged in successfully'}
      end
    else
      render json: {error: 'Invalid Email or Password'}, status: :unprocessable_entity
    end
  end

  def two_factor_auth
    if @user.otp == params[:otp]
      render json: {message: 'You have successfully logged in'}
    else
      render json: {error: 'Otp is not valid'}, status: :unprocessable_entity
    end
  end

  def enable_2fa
    @user.update(enable_2fa: params[:enable_2fa])
    render json: {message: 'Your 2FA request updated successfully'}
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def set_user
    token = request.headers[:token]
    id = JsonWebToken.decode(token)
    @user = User.find_by(id: id)
  end
end
