if Redmine::VERSION::MAJOR < 2
  require 'redmine'
  require_dependency 'messages_controller'

  class MessagesController < ApplicationController

    require_dependency File.expand_path('../../../inc/bw_messages_controller.rb', __FILE__)

    alias_method_chain :new, :watchers
    alias_method_chain :edit, :watchers
    alias_method_chain :reply, :watchers
  end
end
