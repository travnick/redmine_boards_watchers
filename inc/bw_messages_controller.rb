  def new_with_watchers
# Lines added by boards watchers plugin - start
    unless params[:message].nil?
      return new_without_watchers if params[:message]['watcher_user_ids'].blank? && params[:message]['sticky_priority'].blank?
    end
# Lines added by boards watchers plugin - end

    @message=Message.new
    if @message.respond_to?('safe_attributes=')
      @message.author = User.current
      @message.board = @board
      @message.safe_attributes = params[:message]
    else
      @message = Message.new(params[:message])
      @message.author = User.current
      @message.board = @board
    end

# Lines added by boards watchers plugin - start
    if params[:message] && !params[:message]['watcher_user_ids'].blank?
      @message.watcher_user_ids = params[:message]['watcher_user_ids'] if User.current.allowed_to?({:controller => "boards_watchers", :action => "manage_topic"}, @project)
    end

    allowed_to_set_sticky=if @message.respond_to?('safe_attribute?')
      @message.safe_attribute?('sticky') ? true : false
    else
      User.current.allowed_to?(:edit_messages, @project) ? true : false
    end
    if params[:message] && allowed_to_set_sticky
      @message.locked = params[:message]['locked'] unless @message.respond_to?('safe_attributes=')
      sp=params[:message]['sticky_priority'].to_i
      @message.sticky = (sp > 0 ? '1' : '0')
      @message.sticky_priority = sp
# Lines added by boards watchers plugin - end
    end

    if request.post?
      if @message.respond_to?('save_attachments')
        @message.save_attachments(params[:attachments])
      else
        Attachment.attach_files(@message, params[:attachments])
      end
      if @message.save
        call_hook(:controller_messages_new_after_save, { :params => params, :message => @message})
        render_attachment_warning_if_needed(@message)
        redirect_to :action => 'show', :id => @message
      end
    end
  end

  def edit_with_watchers
    if params[:message] && @message.editable_by?(User.current)
      sp=params[:message]['sticky_priority'].to_i
      @message.sticky = (sp > 0 ? '1' : '0')
      @message.sticky_priority = sp
      params[:message]['sticky']='1' if @message.sticky?
    end
    edit_without_watchers
  end

  def reply_with_watchers
    if @topic && params[:bw_watcher_ids] && User.current.allowed_to?({:controller => "boards_watchers", :action => "manage_topic"}, @project)
      watcher_ids=params[:bw_watcher_ids]

      @project.users.sort.each do |user|
        @topic.set_watcher(user,false)
      end

      watcher_ids.each do |w|
        watcher=Watcher.new({ 'user_id' => w })
        watcher.watchable=@topic
        watcher.save
      end if watcher_ids
    end
    reply_without_watchers
  end

