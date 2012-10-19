
class BoardsWatchersController < ApplicationController
  unloadable

  before_filter :setup_environment, :only => [:manage, :manage_topic, :manage_topic_remote]
  before_filter :setup_environment_wiki, :only => :manage_wiki
  before_filter :setup_environment_issues, :only => [:issues_watchers_bulk, :watch_bulk_issues]
  before_filter :authorize, :except => [:issues_watchers_bulk, :watch_bulk_issues]

  def manage
    if request.post?
      update_watchers_for_object_from_params(@board)
      params[:settings_url] ?	redirect_to_settings_in_projects : redirect_to_boards_list
    end
  end

  def manage_topic
    if request.post?
      update_watchers_for_object_from_params(@topic)
      redirect_to_topics_list
    end
  end

  def manage_topic_remote
    @bw_remote_status=(update_watchers_for_object_from_params(@topic) ? 1 : 0)

    render :layout => false
  end

  def manage_wiki
    if request.post?
      update_watchers_for_object_from_params(@page)
      redirect_to_wiki_index
    end
  end

  def watch_bulk_issues
    if @issues
      @issues.each do |issue|
        issue.set_watcher(User.current,params[:unwatch].blank? ? true : false) if (issue.respond_to?(:visible?) && issue.visible?(User.current)) || !issue.respond_to?(:visible?)
      end
    end
    redirect_back_or_default({:controller => 'issues', :action => 'index', :project_id => params[:project_id]})
  end

  def issues_watchers_bulk
    return unless @project

    i=@issues.detect do |issue|
      true if issue.project!=@project
    end

    unless (params[:unwatch].blank? && User.current.allowed_to?(:add_issue_watchers,@project)) ||
       (!params[:unwatch].blank? && User.current.allowed_to?(:delete_issue_watchers,@project))
      i=true
    end

    if i
      redirect_back_or_default({:controller => 'issues', :action => 'index', :project_id => params[:project_id]})
      return
    end

    if request.post?
      watcher_users=(params['watcher_user_ids'] || []).collect do |w|
        u=User.find_by_id(w.to_i)
        (u && u.active? ? u : nil)
      end
      watcher_users.compact!
      watcher_users.uniq!
      unwatch=params[:unwatch].blank? ? false : true

      @issues.each do |issue|
        update_watchers_for_issue(watcher_users,issue,unwatch)
      end

      redirect_back_or_default({:controller => 'issues', :action => 'index', :project_id => params[:project_id]})
      return
    else
      @users=[]
      if params[:unwatch].blank?
        @issues.each do |issue|
          @project.users.each do |user|
            @users << user.id if issue.watched_by?(user)
          end
        end
        @users.uniq!
      end
    end
  end

private

  def setup_environment
    @project=Project.find(params[:project_id])
    @board=Board.find_by_id(params[:board_id]) if params[:board_id]
    render_404 unless @board
    @topic=@board.topics.find_by_id(params[:topic_id]) if params[:topic_id]
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def setup_environment_issues
    @project=nil
    unless params[:issues].blank?
      @issues=Issue.find_all_by_id(params[:issues])
      @project=@issues[0].project if @issues.size > 0
    else
      @issues=nil
      redirect_back_or_default({:controller => 'issues', :action => 'index', :project_id => params[:project_id]})
    end
  end

  def setup_environment_wiki
    @project=Project.find(params[:project_id])
    @wiki=@project.wiki
    @page=@wiki.find_page(params[:id]) if @wiki
    render_404 unless @wiki && @page
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def redirect_to_settings_in_projects
    redirect_to :controller => 'projects', :action => 'settings', :id => @project, :tab => 'boards'
  end

  def redirect_to_topics_list
    redirect_to :controller => 'boards', :action => 'show', :project_id => @project, :id => @board
  end

  def redirect_to_boards_list
    redirect_to :controller => 'boards', :action => 'index', :project_id => @project
  end

  def redirect_to_wiki_index
    redirect_to :controller => 'wiki', :action => 'index', :project_id => @project
  end

  def update_watchers_for_object_from_params(watched_object)
    return false unless watched_object

    watcher_ids=params['watcher_user_ids']

    @project.users.sort.each do |user|
      watched_object.set_watcher(user,false)
    end

    watcher_ids.each do |w|
      watcher=Watcher.new({ 'user_id' => w })
      watcher.watchable=watched_object
      watcher.save
    end if watcher_ids

    return true
  end

  def update_watchers_for_issue(watcher_users,watched_object,unwatch)
    return false unless watched_object

    watcher_users.each do |w|
      if unwatch
        watched_object.set_watcher(w,false) if watched_object.watched_by?(w)
      else
        unless watched_object.watched_by?(w)
          watcher=Watcher.new({ 'user_id' => w.id.to_s })
          watcher.watchable=watched_object
          watcher.save
        end
      end
    end

    return true
  end

end

