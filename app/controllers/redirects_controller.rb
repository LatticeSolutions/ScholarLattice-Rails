class RedirectsController < ApplicationController
  def index
    redirect_to request.path, subdomain: nil, status: :moved_permanently, allow_other_host: true
  end
end
