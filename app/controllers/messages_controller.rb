require 'redmine'
require_dependency 'messages_controller'

class MessagesController < ApplicationController

  # Create a new topic
  def new_with_watchers
# Lines added by boards watchers plugin - start
	  return new_without_watchers if params[:message]['watcher_user_ids'].blank?
# Lines added by boards watchers plugin - end

    @message = Message.new(params[:message])
    @message.author = User.current
    @message.board = @board
	  
# Lines added by boards watchers plugin - start
	  unless params[:message]['watcher_user_ids'].blank?
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

end
