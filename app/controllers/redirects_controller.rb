class RedirectsController < ApplicationController
  def index
    redirect_to "#{request.protocol}#{request.domain}#{request.fullpath}",
      status: :moved_permanently, allow_other_host: true
  end
end
