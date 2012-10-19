require 'bw_asset_helpers'

class BoardsWatchersHook < Redmine::Hook::ViewListener
  def view_layouts_base_html_head(context = {})
    stylesheet_link_tag('boards_watchers', :plugin => BW_AssetHelpers::PLUGIN_NAME.to_s)
  end

  # * :issues
  # * :can
  # * :back
  def view_issues_context_menu_end(context={})

    ret_str=''

    watched_list=[]
    nonwatched_list=[]
    target_project=context[:issues][0].project
    menu_exists=false

    context[:issues].each do |issue|
      if issue.author != User.current
        issue.watched_by?(User.current) ? watched_list << issue : nonwatched_list << issue
      end
      target_project=nil if target_project!=nil && issue.project!=target_project
    end

    ret_str << "<li class=\"folder\">"
    ret_str << "<a href=\"#\" class=\"submenu\" onclick=\"return false;\">#{l(:label_issue_watchers)}</a>"
    ret_str << '<ul>'

    if target_project && User.current.allowed_to?(:add_issue_watchers,target_project)
      ret_str << "<li>#{bw_context_menu_link("#{l(:permission_add_issue_watchers)}",
                        {:controller => 'boards_watchers', :action => 'issues_watchers_bulk', :issues => context[:issues], :back_url => context[:back]})}</li>"
      menu_exists=true
    end

    if target_project && User.current.allowed_to?(:delete_issue_watchers,target_project)
      ret_str << "<li>#{bw_context_menu_link("#{l(:permission_delete_issue_watchers)}",
                        {:controller => 'boards_watchers', :action => 'issues_watchers_bulk', :unwatch => true, :issues => context[:issues], :back_url => context[:back]})}</li>"
      menu_exists=true
    end

    if nonwatched_list.size > 0
      ret_str << "<li>#{bw_context_menu_link("#{l(:button_watch)}",
                        {:controller => 'boards_watchers', :action => 'watch_bulk_issues', :issues => nonwatched_list.collect(&:id), :back_url => context[:back]},
                        :class => 'icon icon-fav')}</li>"
      menu_exists=true
    end
    if watched_list.size > 0
      ret_str << "<li>#{bw_context_menu_link("#{l(:button_unwatch)}",
                        {:controller => 'boards_watchers', :action => 'watch_bulk_issues', :issues => watched_list.collect(&:id), :back_url => context[:back], :unwatch => true},
                        :class => 'icon icon-fav-off')}</li>"
      menu_exists=true
    end

    ret_str << "</ul></li>"

    ret_str='' unless menu_exists

    return ret_str.html_safe
  end

private

  def bw_context_menu_link(name, url, options={})
    options[:class] ||= ''
    if options.delete(:selected)
      options[:class] << ' icon-checked disabled'
      options[:disabled] = true
    end
    if options.delete(:disabled)
      options.delete(:method)
      options.delete(:confirm)
      options.delete(:onclick)
      options[:class] << ' disabled'
      url = '#'
    end

    if url.is_a?(Hash) && Rails::VERSION::MAJOR >= 3 && Redmine::Utils::relative_url_root != ''
      url="#{Redmine::Utils::relative_url_root}#{url_for(url.merge(:only_path => true))}"
    end
    link_to h(name), url, options
  end

end

