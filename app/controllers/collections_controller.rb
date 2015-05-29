class CollectionsController < ApplicationController
  def new
    @collection = Collection.new

    if @idea = Idea.find_by_sha(params[:idea_id])
      @collection.ideas << @idea
    end
  end

  def show
    @collection = Collection.find_by_sha(params[:id])
  end

  def create
    @collection = Collection.new(collection_params)
    @collection.user = current_user

    @idea = Idea.find_by_sha(params[:collection][:idea_id])

    if @collection.save
      @collection.ideas << @idea
      redirect_to collection_path(@collection), :notice => "Collection created"
    end
  end

  def edit

  end

  def add_idea
    @collection = Collection.find_by_sha(params[:id])
    @idea = Idea.find_by_sha(params[:idea_id])
    @collection.ideas << @idea
    redirect_to collection_path(@collection), :notice => "Idea added"
  end

private

  def collection_params
    params.require(:collection).permit(:name, :description)
  end
end
