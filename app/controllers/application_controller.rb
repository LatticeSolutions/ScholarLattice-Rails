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

  def require_unauth!
    unless @current_user.nil?
      redirect_to dashboard_path, notice: "You are already signed in."
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

  def redirect_to_if_allowed(url)
    allowed_domains = [
      "scholarlattice.org",
      "zoom.us",
      "zulipchat.com",
      "google.com",
      "slack.com",
      "discord.com"
    ]
    uri = URI.parse(url) rescue nil
    apex_domain = uri.host.split(".").last(2).join(".") if uri&.host.present?
    if uri.present? && allowed_domains.include?(apex_domain)
      redirect_to url, status: :moved_permanently, allow_other_host: true
    else
      redirect_to(root_url, alert: "Redirects to `#{apex_domain}` are not supported.")
    end
  end
end
