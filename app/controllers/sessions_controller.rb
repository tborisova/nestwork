class SessionsController < ApplicationController
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def new
  end

  def create
    email = params[:email].to_s.strip.downcase
    password = params[:password].to_s

    user = User.find_by(email: email)

    if user&.authenticate(password)
      session[:user_id] = user.id

      redirect_to root_path, notice: "Signed in successfully"
    else
      flash.now[:alert] = "Invalid email or password"

      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to new_session_path, notice: "Signed out"
  end
end
