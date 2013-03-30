#!/bin/env ruby
# encoding: utf-8
require 'redmine'
require 'dispatcher' unless Rails::VERSION::MAJOR >= 3
require 'bw_asset_helpers'

unless Redmine::Plugin.registered_plugins.keys.include?(BW_AssetHelpers::PLUGIN_NAME)
  Redmine::Plugin.register BW_AssetHelpers::PLUGIN_NAME do
    name 'Extended watchers management and sticky priority levels add-on'
    author 'Vitaly Klimov, Kim Pepper, Mikołaj Milej'
    author_url 'mailto:vitaly.klimov@snowbirdgames.com'
    description 'Plugin creates three levels of sticky messages and allows managing of forums/topics/wikis watchers'
    version '0.2.7'
    requires_redmine :version_or_higher => '1.3.0'

    project_module :boards do
      permission :delete_board_watchers, {:boards_watchers => [:manage] }, :require => :member
      permission :delete_message_watchers, {:boards_watchers => [:manage_topic, :manage_topic_remote] }, :require => :member
    end

    project_module :wiki do
      permission :delete_wiki_watchers, {:boards_watchers => [:manage_wiki] }, :require => :member
    end
  end

  require 'boards_watchers_hooks'
end

if Rails::VERSION::MAJOR >= 3
  ActionDispatch::Callbacks.to_prepare do
    require 'boards_watchers_patches'
  end
else
  Dispatcher.to_prepare BW_AssetHelpers::PLUGIN_NAME do
    require_dependency 'boards_watchers_patches'
  end
end
