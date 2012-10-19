require_dependency 'application_helper' if ENV['RAILS_ENV'] == 'production'
require 'message'

module BoardsWatchers
  module Patches
    module StickyPriorityMessagePatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable

          if (Redmine::VERSION.to_a[0..2] <=> [1,3,3]) < 0
            attr_protected :sticky_priority
          else
            safe_attributes 'sticky_priority',
                :if => lambda {|message, user| user.allowed_to?(:edit_messages, message.project) }
          end
        end
      end

      module InstanceMethods
        def sticky_priority=(arg)
          if sticky?
            new_priority=arg.to_i
            new_priority=1 if new_priority == 0
            write_attribute :sticky_priority, new_priority
          else
            write_attribute :sticky_priority, 0
          end
        end

        def sticky_priority
          sp=read_attribute(:sticky_priority) || 0
          sp=1 if sp==0 && sticky?
          sp
        end
      end
    end

    module ApplicationHelperPatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable

          alias_method_chain :render_page_hierarchy, :watchers
        end
      end

      module InstanceMethods
        def render_page_hierarchy_with_watchers(pages, node=nil, options={})
          content = ''
          if pages[node]
            content << "<ul class=\"pages-hierarchy\">\n"
            pages[node].each do |page|
              content << "<li>"
              content << link_to(h(page.pretty_title), {:controller => 'wiki', :action => 'show', :project_id => page.project, :id => page.title},
                                 :title => (options[:timestamp] && page.updated_on ? l(:label_updated_time, distance_of_time_in_words(Time.now, page.updated_on)) : nil))
              if authorize_for("boards_watchers", "manage_wiki")
                content << link_to("(#{page.watcher_users.size})", {:controller => 'boards_watchers', :action => 'manage_wiki', :project_id => @project, :id => page.title}, :class => (page.watcher_users.size > 0 ? 'icon icon-fav' : 'icon icon-fav-off'))
              end
              content << "\n" + render_page_hierarchy(pages, page.id, options) if pages[page.id]
              content << "</li>\n"
            end
            content << "</ul>\n"
          end
          content.html_safe
        end
      end
    end

    if Redmine::VERSION::MAJOR >= 2
      module BoardsControllerPatch
        def self.included(base) # :nodoc:
          base.send(:include, InstanceMethods)
          base.class_eval do
            unloadable

            alias_method_chain :show, :sp
          end
        end

        module InstanceMethods
          require_dependency File.expand_path('../../inc/bw_boards_controller.rb', __FILE__)
        end
      end

      module MessagesControllerPatch
        def self.included(base) # :nodoc:
          base.send(:include, InstanceMethods)
          base.class_eval do
            unloadable

            alias_method_chain :new, :watchers
            alias_method_chain :edit, :watchers
            alias_method_chain :reply, :watchers
          end
        end

        module InstanceMethods
          require File.expand_path('../../inc/bw_messages_controller.rb', __FILE__)
        end
      end
    end

  end
end

unless Message.included_modules.include? BoardsWatchers::Patches::StickyPriorityMessagePatch
  Message.send(:include, BoardsWatchers::Patches::StickyPriorityMessagePatch)
end

if (Rails::VERSION::MAJOR < 3 && ENV['RAILS_ENV'] == 'production') || (Rails::VERSION::MAJOR >= 3 && Rails.env.production?)
  unless ApplicationHelper.included_modules.include? BoardsWatchers::Patches::ApplicationHelperPatch
    ApplicationHelper.send(:include, BoardsWatchers::Patches::ApplicationHelperPatch)
  end
end

if Redmine::VERSION::MAJOR >= 2
  unless BoardsController.included_modules.include? BoardsWatchers::Patches::BoardsControllerPatch
    BoardsController.send(:include, BoardsWatchers::Patches::BoardsControllerPatch)
  end

  unless MessagesController.included_modules.include? BoardsWatchers::Patches::MessagesControllerPatch
    MessagesController.send(:include, BoardsWatchers::Patches::MessagesControllerPatch)
  end
end
