class CollectionsController < ApplicationController
  before_action :set_collection, only: %i[ show like dislike destroy ]
  before_action :require_admin!, only: %i[ new_subcollection edit update ]
  before_action :require_user!, only: %i[ like dislike ]
  before_action :require_site_admin!, only: %i[ new destroy ]

  def index
    @collections = Collection.roots
  end

  def show
  end

  def new
    @collection = Collection.new
  end

  def new_subcollection
    @subcollection = Collection.new parent_id: @collection.id
  end

  def create
    @collection = Collection.new collection_params
    if @collection.parent and !@current_user.can_administrate?(@collection.parent)
      redirect_to collection_path(@collection.parent), alert: "You are not authorized to access this page."
    elsif @collection.parent.nil? and !@current_user.site_admin
      redirect_to collections_path, alert: "You are not authorized to access this page."
    elsif @collection.save
      redirect_to @collection
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @collection.update(collection_params)
      redirect_to @collection
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @collection.destroy
    redirect_to collections_path, status: :see_other
  end

  def like
    likes = Like.where collection: @collection, user: @current_user
    if likes.empty?
      Like.create! collection: @collection, user: @current_user
      flash.notice = "#{@collection.short_title} is now a favorite!"
    else
      flash.notice = "#{@collection.short_title} is already a favorite."
    end
    redirect_to @collection
  end

  def dislike
    likes = Like.where collection: @collection, user: @current_user
    if likes.empty?
      flash.notice = "#{@collection.short_title} isn't a favorite."
    else
      likes.destroy_all
      flash.notice = "#{@collection.short_title} is no longer a favorite."
    end
    redirect_to @collection
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_collection
      @collection = Collection.find(params[:id])
    end

    def collection_params
      params.require(:collection).permit(
        :title, :short_title, :description, :parent_id, :subcollection_name, :submittable, :admin_emails
      )
    end

    def require_admin!
      require_user! or return false
      set_collection
      return true if @current_user.can_administrate? @collection
      redirect_to collection_path(@collection), alert: "You are not authorized to access this page."
      false
    end
end
