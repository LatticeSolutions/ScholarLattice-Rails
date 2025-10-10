class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :redirect_subdomains

  # passwordless
  include Passwordless::ControllerHelpers
  before_action :current_user


  private

  def current_user
    @current_user ||= authenticate_by_session(User)
  end

  def require_unauth!
    unless @current_user.nil?
      redirect_to dashboard_path, notice: "You are already signed in."
    end
  end

  def redirect_subdomains
    if Rails.env.production? && request.subdomain.present?
      redirect_to url_for(request.params.merge(subdomain: nil)), status: :moved_permanently, allow_other_host: true
    end
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
