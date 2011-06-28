
class BoardsWatchersController < ApplicationController
  unloadable

  before_filter :setup_environment
  before_filter :authorize

  def manage
	  if request.post?
		  params[:settings_url] ?	redirect_to_settings_in_projects : redirect_to_boards_list
		end
  end

  def manage_topic
		redirect_to_topics_list if request.post?
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

	def redirect_to_settings_in_projects
		redirect_to :controller => 'projects', :action => 'settings', :id => @project, :tab => 'boards'
	end

  def redirect_to_topics_list
	  redirect_to :controller => 'boards', :action => 'show', :project_id => @project, :id => @board
  end

  def redirect_to_boards_list
	  redirect_to :controller => 'boards', :action => 'index', :project_id => @project
  end
	
end

