class DashboardController < ApplicationController
  def index
    redirect_to root_path unless can? :read, :dashboard
  end
end
