class CollectionsController < ApplicationController
  def index
    @collections = Collection.roots
  end

  def show
    @collection = Collection.find(params[:id])
  end

  def new
    require_site_admin!
    @collection = Collection.new
  end

  def new_subcollection
    @parent = Collection.find(params[:id])
    require_admin! @parent
    @collection = Collection.new parent_id: @parent.id
  end

  def create
    @collection = Collection.new collection_params
    if @collection.parent
      require_admin! @collection.parent
    else
      require_site_admin!
    end

    if @collection.save
      redirect_to @collection
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @collection = Collection.find(params[:id])
    require_admin! @collection
  end

  def update
    @collection = Collection.find(params[:id])
    require_admin! @collection

    if @collection.update(collection_params)
      redirect_to @collection
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    require_site_admin!
    @collection = Collection.find(params[:id])
    @collection.destroy

    redirect_to collections_path, status: :see_other
  end


  private
    def collection_params
      params.require(:collection).permit(
        :title, :short_title, :description, :parent_id
      )
    end

    def require_admin!(collection)
      if @current_user.nil?
        save_passwordless_redirect_location!(User)
        redirect_to users_sign_in_path, alert: "You must be logged in to access this page."
      else
        return if collection.has_admin? @current_user
        redirect_to collection_path(collection), alert: "You are not authorized to access this page."
      end
    end
end
