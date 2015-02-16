class IdeasController < ApplicationController
  before_filter :require_user, :only => [ :new, :create, :hide ]
  respond_to :json, :html, :atom

  def index
    @ideas = Idea.by_date.recent.visible.for_user(current_user).paginate(:page => params[:page], :per_page => 10)

    respond_to do |format|
      format.atom
      format.json { render :json => @ideas }
      format.html
    end
  end

  def trending
    @ideas = Idea.trending.visible.by_date.for_user(current_user).paginate(:page => params[:page], :per_page => 10)
    @trending = true

    respond_to do |format|
      format.atom { render :template => 'ideas/index' }
      format.json { render :json => @ideas }
      format.html { render :template => 'ideas/index' }
    end
  end

  def all
    @ideas = Idea.by_date.visible.for_user(current_user).paginate(:page => params[:page], :per_page => 10)
    @all = true

    respond_to do |format|
      format.atom { render :template => 'ideas/index' }
      format.json { render :json => @ideas }
      format.html { render :template => 'ideas/index' }
    end
  end

  def new
    @tags = Idea.all_tags
    @idea = Idea.new
  end

  def create
    @idea = Idea.new(idea_params)
    @idea.tags = idea_params['tags'].split(',').collect(&:strip).collect(&:downcase)
    @idea.user = current_user

    if @idea.save
      redirect_to idea_path(@idea), :notice => "Idea created"
    else
      render :action => "new"
    end
  end

  def preview
    filter = HTML::Pipeline::MarkdownFilter.new(params[:idea])
    render :text => filter.call
  end

  def hide
    @idea = Idea.find_by_sha(params[:id])
    current_user.dismiss!(@idea)
    redirect_to(:back, :notice => "Idea hidden")
  end

  def similar
    @ideas = Idea.similar_ideas(params[:idea])

    respond_to do |format|
      format.html { render :layout => false }
    end
  end

  def tags
    render :json => Idea.all_tags.to_json
  end

  def show
    @idea = Idea.find_by_sha(params[:id])

    impressionist(@idea)

    respond_to do |format|
      format.html
      format.json { render :json => @idea }
    end
  end

  def about

  end

  def lookup_title
    @results = Idea.fuzzy_search_by_title(params[:query]).limit(3)
    respond_with @results
  end

  private

  def idea_params
    params.require(:idea).permit(:title, :body, :subject, :tags, :citation_ids)
  end
end
