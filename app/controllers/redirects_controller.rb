class RedirectsController < ApplicationController
  def index
    redirect_to request.path, subdomain: "", status: :moved_permanently, allow_other_host: true
  end
end
