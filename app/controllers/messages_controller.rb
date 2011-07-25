require 'redmine'
require_dependency 'messages_controller'

class MessagesController < ApplicationController

  # Create a new topic
  def new_with_watchers
# Lines added by boards watchers plugin - start
		unless params[:message].nil?
			unless  params[:message]['watcher_group_ids'].blank?
				params[:message]['watcher_user_ids']=update_watchers_from_group_watchers(params[:message]['watcher_user_ids'],params[:message]['watcher_group_ids'])
				params[:message].delete('watcher_group_ids')
			end

	    return new_without_watchers if params[:message]['watcher_user_ids'].blank?
		end
# Lines added by boards watchers plugin - end

    @message = Message.new(params[:message])
    @message.author = User.current
    @message.board = @board
	  
# Lines added by boards watchers plugin - start
	  if params[:message] && !params[:message]['watcher_user_ids'].blank?
	    @message.watcher_user_ids = params[:message]['watcher_user_ids'] if User.current.allowed_to?({:controller => "boards_watchers", :action => "manage_topic"}, @project) 
		end
# Lines added by boards watchers plugin - end

    if params[:message] && User.current.allowed_to?(:edit_messages, @project)
      @message.locked = params[:message]['locked']
      @message.sticky = params[:message]['sticky']
    end
    if request.post? && @message.save
      call_hook(:controller_messages_new_after_save, { :params => params, :message => @message})
      attachments = Attachment.attach_files(@message, params[:attachments])
      render_attachment_warning_if_needed(@message)
      redirect_to :action => 'show', :id => @message
    end
  end

	alias_method_chain :new, :watchers

private
	def update_watchers_from_group_watchers(watcher_user_ids,watcher_group_ids)

		if watcher_group_ids.size > 0
			watcher_user_ids = Array.new unless watcher_user_ids
			watcher_group_ids.each do |wg|
				grp=Group.find_by_id(wg.to_i)
				grp.users.each do |u|
					watcher_user_ids << u.id.to_s if u.active?
				end if grp
			end
			watcher_user_ids.uniq!
		end
		return watcher_user_ids
	end
end
