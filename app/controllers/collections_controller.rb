class CollectionsController < ApplicationController
  def index
    @collections = Collection.where(parent_id: nil)
  end

  def show
    @collection = Collection.find(params[:id])
  end

  def new
    @collection = Collection.new
  end

  def create
    @collection = Collection.new collection_params

    if @collection.save
      redirect_to @collection
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @collection = Collection.find(params[:id])
  end

  def update
    @collection = Collection.find(params[:id])

    if @collection.update(collection_params)
      redirect_to @collection
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @collection = Collection.find(params[:id])
    @collection.destroy

    redirect_to collections_path, status: :see_other
  end


  private
    def collection_params
      params.require(:collection).permit(
        :title, :short_title, :description, :website, :parent_id
      )
    end
end
