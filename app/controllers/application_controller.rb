class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_user

  private

  def current_user
    return @current_user if defined?(@current_user)
    user_id = session[:user_id]
    @current_user = user_id.present? ? User.find_by(id: user_id) : nil
  end
end
