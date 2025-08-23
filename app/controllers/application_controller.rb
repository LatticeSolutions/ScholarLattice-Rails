class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # passwordless
  include Passwordless::ControllerHelpers
  before_action :current_user

  private

  def current_user
    @current_user ||= authenticate_by_session(User)
  end

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden }
      if current_user
        format.html { redirect_to dashboard_path, alert: exception.message }
      else
        format.html { redirect_to users_sign_in_path }
      end
    end
  end
end
