class RedirectsController < ApplicationController
  def index
    redirect_to "/", subdomain: nil, status: :moved_permanently, allow_other_host: true
  end
end
