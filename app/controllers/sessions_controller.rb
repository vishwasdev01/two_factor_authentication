class SessionsController < ApplicationController
  before_action :require_auth, only: [:add_otp, :otp,:qr]
  before_action :verify_otp_status, only: [:add_otp]

  def new
  end

  def create
    @user = User.find_by(email: session_params[:email])
    if @user && @user.authenticate(session_params[:password])
      session[:user_id] = @user.id
      session[:otp_passed] = false
      if !@user.verified || @user.otp_enabled
        @user.update(verified: true)
        session[:otp] = @user.generate_otp
        UserMailer.send_otp(@user.email, session[:otp]).deliver_now
        redirect_to otp_authenticate_path
      else
        redirect_to root_path
      end
    else
      flash[:error] = "Email or password is invalid!"
      redirect_to action: :new
    end
  end

  def otp
    otp_code = params[:otp_code]
    if @user.authenticate_otp(otp_code)
      session[:otp_passed] = true
      redirect_to root_path
    else
      flash[:error] = "Invalid OTP code"
      redirect_to otp_path
    end
  end

  def add_otp
    otp_code = params[:otp_code]
    if @user.authenticate_otp(otp_code, drift: 60)
      @user.update!(otp_enabled: true)
      redirect_to root_path
    else
      flash[:error] = "Invalid OTP code"
      redirect_to enable_2fa_path
    end
  end

  def enable_2fa
    @user = current_user
  end

  def disable_2fa
    @user = current_user
    @user.update(otp_enabled: false)
    redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    session[:otp_passed] = false
    redirect_to root_path
  end

  def verify_otp
    if session[:otp] == params[:otp]
      session[:otp_passed] = true
      redirect_to root_path
    else
      flash[:error] = "Invalid OTP. Please try again."
      redirect_to action: :otp_authenticate
    end
  end
  
  def otp_authenticate
  end

  def qr
    require "rqrcode"
    totp = ROTP::TOTP.new(@user.otp_secret_key, issuer: "OTP Test")
    qrcode = RQRCode::QRCode.new(totp.provisioning_uri(@user.email))
    send_data qrcode.as_png(size: 500), type: 'image/png', disposition: 'inline'
  end

  private

  def session_params
    params.require(:session).permit(:email, :password)
  end
end
