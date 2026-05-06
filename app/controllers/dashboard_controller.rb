class DashboardController < ApplicationController
  def index
    authorize! :read, :dashboard
  end

  def subscribe
    @current_user.mailkick_subscribe("site_emails")
    redirect_to dashboard_path, alert: "You are now subscribed to email updates."
  end

  def unsubscribe
    @current_user.mailkick_unsubscribe("site_emails")
    redirect_to dashboard_path, alert: "You are now unsubscribed from email updates."
  end
end
