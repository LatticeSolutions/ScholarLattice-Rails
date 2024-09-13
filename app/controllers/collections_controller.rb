class CollectionsController < ApplicationController
  def index
    @collections = Collection.roots
  end

  def show
    @collection = Collection.find(params[:id])
  end

  def new
    @collection = Collection.new
  end

  def new_subcollection
    @parent = Collection.find(params[:id])
    return unless require_admin! @parent
    @collection = Collection.new parent_id: @parent.id
  end

  def create
    @collection = Collection.new collection_params
    if @collection.parent
      return unless require_admin! @collection.parent
    else
      return unless require_site_admin!
    end

    if @collection.save
      redirect_to @collection
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @collection = Collection.find(params[:id])
    nil unless require_admin! @collection
  end

  def update
    @collection = Collection.find(params[:id])
    return unless require_admin! @collection

    if @collection.update(collection_params)
      redirect_to @collection
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    return unless require_site_admin!
    @collection = Collection.find(params[:id])
    @collection.destroy

    redirect_to collections_path, status: :see_other
  end

  def like
    return unless require_user!
    @collection = Collection.find(params[:id])
    likes = Like.where collection: @collection, user: current_user
    if likes.empty?
      Like.create! collection: @collection, user: current_user
      flash.notice = "#{@collection.short_title} is now a favorite!"
    else
      flash.notice = "#{@collection.short_title} is already a favorite."
    end
    redirect_to @collection
  end

  def dislike
    return unless require_user!
    @collection = Collection.find(params[:id])
    likes = Like.where collection: @collection, user: current_user
    if likes.empty?
      flash.notice = "#{@collection.short_title} isn't a favorite."
    else
      likes.destroy_all
      flash.notice = "#{@collection.short_title} is no longer a favorite."
    end
    redirect_to @collection
  end


  private
    def collection_params
      params.require(:collection).permit(
        :title, :short_title, :description, :parent_id, :subcollection_name
      )
    end

    def require_admin!(collection)
      if @current_user.nil?
        save_passwordless_redirect_location!(User)
        redirect_to users_sign_in_path, alert: "You must be logged in to access this page."
        false
      else
        return if collection.has_admin? @current_user or @current_user.site_admin
        redirect_to collection_path(collection), alert: "You are not authorized to access this page."
        true
      end
    end
end
