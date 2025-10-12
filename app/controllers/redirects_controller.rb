class RedirectsController < ApplicationController
  def index
    redirect_to "/", status: :moved_permanently, allow_other_host: true
  end
end
