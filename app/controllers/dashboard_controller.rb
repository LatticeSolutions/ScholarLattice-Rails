class DashboardController < ApplicationController
  def index
    require_user!
  end
end
