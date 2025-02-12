class CollectionsController < ApplicationController
  load_and_authorize_resource

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
    if @collection.save
      redirect_to @collection, notice: "Collection was successfully created."
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
    @collection.destroy!
    redirect_to collections_path, status: :see_other
  end

  def like
    can? :like, @collection
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
    can? :like, @collection
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

    def collection_params
      params.require(:collection).permit(
        :title, :short_title, :description, :parent_id, :subcollection_name, :submittable, :admin_emails
      )
    end
end
