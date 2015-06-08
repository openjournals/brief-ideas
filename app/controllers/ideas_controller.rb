class IdeasController < ApplicationController
  before_filter :require_user, :only => [ :new, :edit, :create, :hide, :accept_invite, :submit, :update ]
  before_filter :load_tags, :only => [ :new, :edit ]
  respond_to :json, :html, :atom

  def index
    @ideas = Idea.by_date.visible.for_user(current_user).limit(10)
    @recent = true

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
    @idea = Idea.new

    if params[:tags]
      @idea.tags = params[:tags].split(",").collect(&:strip)
    end

    # Are we automagically adding it to a collection on creation?
    @collection = Collection.find_by_sha(params[:collection_id]) if params[:collection_id]
  end

  def create
    @idea = Idea.new(idea_params)
    @idea.tags = idea_params['tags_list'].split(',').collect(&:strip).collect(&:downcase)
    @idea.authors << current_user

    if @idea.save
      associate_collection
      redirect_to idea_path(@idea), :notice => "Idea created"
    else
      render :action => "new"
    end
  end

  # Add this idea to a collection if it's open
  def associate_collection
    if params["collection_id"] && collection = Collection.find_by_sha(params["collection_id"])
      collection.ideas << @idea if collection.open?
    end
  end

  def edit
    @idea = Idea.find_by_sha(params[:id])

    unless @idea.pending?
      redirect_to ideas_path, :notice => "This idea can't be edited" and return
    end

    unless @idea.authors.include?(current_user)
      redirect_to ideas_path, :notice => "You don't have permissions to edit this idea" and return
    end
  end

  def update
    @idea = Idea.find_by_sha(params[:id])

    unless @idea.pending?
      redirect_to ideas_path, :notice => "This idea can't be edited" and return
    end

    unless @idea.authors.include?(current_user)
      redirect_to ideas_path, :notice => "You don't have permissions to edit this idea" and return
    end

    @idea.tags = idea_params['tags_list'].split(',').collect(&:strip).collect(&:downcase)

    if @idea.update_attributes(idea_params)
      redirect_to idea_path(@idea), :notice => "Idea updated"
    else
      render :action => "edit"
    end
  end

  def add_comment
    @idea = Idea.find_by_sha(params[:id])
    @comment = @idea.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      respond_to do |format|
        format.js
        format.html { redirect_to(:back, :notice => "Comment added")}
      end
    else
      redirect_to(:back)
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

    unless @idea
      redirect_to ideas_path, :notice => "Idea not found" and return
    end

    impressionist(@idea)

    respond_to do |format|
      format.html
      format.json { render :json => @idea }
    end
  end

  def about

  end

  def submit
    @idea = Idea.find_by_sha(params[:id])

    # Only let the submitting author submit an idea
    unless @idea.submitting_author == current_user
      redirect_to idea_path(@idea), :notice => "Only the submitting author can submit an idea" and return
    end

    if @idea.pending?
      @idea.submit!
      redirect_to idea_path(@idea), :notice => "Idea submitted"
    else
      redirect_to idea_path(@idea), :notice => "Your idea could not be submitted"
    end
  end

  def accept_invite
    @idea = Idea.find_by_sha(params[:id])
    valid_author, message = @idea.can_become_author?(current_user)

    if current_user.email.blank?
      redirect_to idea_path(@idea), :notice => "You must add an email to your account before becoming an authorship"
    elsif !valid_author
      redirect_to idea_path(@idea), :notice => message
    else
      @idea.add_author!(current_user)
      redirect_to idea_path(@idea), :notice => "Authorship accepted!"
    end
  end

  def boom
    raise "Hell"
  end

  def lookup_title
    @results = Idea.fuzzy_search_by_title(params[:query]).limit(3)
    respond_with @results
  end

private

  def idea_params
    params.require(:idea).permit(:title, :body, :subject, :tags_list, :citation_ids, :attachment)
  end

  def comment_params
    params.require(:comment).permit(:comment)
  end

  def load_tags
    @all_tags = Idea.all_tags
  end
end
