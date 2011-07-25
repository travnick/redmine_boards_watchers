
class BoardsWatchersController < ApplicationController
  unloadable

  before_filter :setup_environment
  before_filter :authorize

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

private
	def update_watchers_from_group_watchers(watcher_user_ids,watcher_group_ids)

		if watcher_group_ids.size > 0
			watcher_user_ids = Array.new unless watcher_user_ids
			watcher_group_ids.each do |wg|
				grp=Group.find_by_id(wg.to_i)
				grp.users.each do |u|
					watcher_user_ids << u.id.to_s
				end if grp
			end
			watcher_user_ids.uniq!
		end
		return watcher_user_ids
	end

	def update_watchers_for_object_from_params(watched_object)
		return unless watched_object

		watcher_ids=unless params['watcher_group_ids'].blank?
			update_watchers_from_group_watchers(params['watcher_user_ids'],params['watcher_group_ids'])
		else
			params['watcher_user_ids']
		end

		@project.users.sort.each do |user|
			watched_object.set_watcher(user,false)
		end

		watcher_ids.each do |w|
			watcher=Watcher.new({ 'user_id' => w })
			watcher.watchable=watched_object
			watcher.save
		end if watcher_ids
	end

end

