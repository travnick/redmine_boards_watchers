if Redmine::VERSION::MAJOR < 2
  require_dependency 'boards_controller'

  class BoardsController < ApplicationController
    require_dependency File.expand_path('../../../inc/bw_boards_controller.rb', __FILE__)

    alias_method_chain :show, :sp
  end
end
