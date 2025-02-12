class DashboardController < ApplicationController
  def index
    redirect_to new_profile_path, alert: "You must create a profile." unless can? :read, :dashboard
  end
end
