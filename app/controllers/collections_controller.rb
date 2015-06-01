class CollectionsController < ApplicationController
  before_filter :require_user, :except => [ :show  ]

  def new
    @collection = Collection.new

    if @idea = Idea.find_by_sha(params[:idea_id])
      @collection.ideas << @idea
    end
  end

  def show
    @collection = Collection.find_by_sha(params[:id])

    respond_to do |format|
      format.atom { render :atom => @collection, :include => [ :ideas ] }
      format.json { render :json => @collection, :include => [ :ideas ] }
      format.html
    end
  end

  def create
    @collection = Collection.new(collection_params)
    @collection.user = current_user

    if @collection.save
      set_ideas
      redirect_to collection_path(@collection), :notice => "Collection created"
    end
  end

  def edit
    @collection = Collection.find_by_sha(params[:id])
    redirect_to collections_path, :warning => "Collection not found" unless @collection

    # Redirect if not owner
    redirect_to collection_path(@collection) unless @collection.owner == current_user
  end

  def update
    @collection = Collection.find_by_sha(params[:id])
    redirect_to collections_path, :warning => "Collection not found" unless @collection
    redirect_to collection_path(@collection) unless @collection.owner == current_user

    set_ideas

    redirect_to collection_path(@collection), :notice => "Collection updated"
  end

  def add_idea
    @collection = Collection.find_by_sha(params[:id])
    @idea = Idea.find_by_sha(params[:idea_id])
    @collection.ideas << @idea unless @collection.ideas.include?(@idea)
    redirect_to collection_path(@collection), :notice => "Idea added"
  end

  def destroy
    @collection = Collection.find_by_sha(params[:id])
    redirect_to collections_path, :warning => "Collection not found" unless @collection
    redirect_to collection_path(@collection) unless @collection.owner == current_user

    if @collection.destroy
      redirect_to collections_path, :warning => "Collection deleted"
    end
  end

private

  def set_ideas
    @collection.collection_ideas.destroy_all

    # This will be empty if there are no ideas
    return true unless params['collection']['ideas']

    params['collection']['ideas'].each do |_, idea_sha|
      @idea = Idea.find_by_sha(idea_sha)
      @collection.ideas << @idea if @idea
    end
  end

  def collection_params
    params.require(:collection).permit(:name, :description)
  end
end
