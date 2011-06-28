require 'redmine'

unless Redmine::Plugin.registered_plugins.keys.include?(:redmine_boards_watchers)
	Redmine::Plugin.register :redmine_boards_watchers do
	  name 'Boards watchers management plugin'
	  author 'Vitaly Klimov'
	  author_url 'mailto:vvk@snowball.ru'
	  description 'Plugin for managing boards/topics watchers'
	  version '0.0.5'

		project_module :boards do
			permission :delete_board_watchers, {:boards_watchers => [:manage] }, :require => :member
			permission :delete_message_watchers, {:boards_watchers => [:manage_topic] }, :require => :member
		end
	end

end

