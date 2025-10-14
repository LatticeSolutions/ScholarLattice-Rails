class RedirectsController < ApplicationController
  def index
    if request.subdomain.present?
      redirect = Redirect.find_by(slug: request.subdomain)
      redirect_to_if_allowed redirect.target_url if redirect.present?
    end
    redirect_to "#{request.protocol}#{request.domain}#{request.fullpath}",
      status: :moved_permanently, allow_other_host: true
  end

  def show
    redirect = Redirect.find_by(slug: params[:slug])
    if redirect.present?
      redirect_to_if_allowed redirect.target_url
    else
      render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
    end
  end
end
