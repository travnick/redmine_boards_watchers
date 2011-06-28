ActionController::Routing::Routes.draw do |map|
  map.with_options :controller => 'boards_watchers' do |bw_routes|
    bw_routes.with_options :conditions => {:method => :get} do |bw_views|
	    bw_views.connect 'projects/:project_id/boards/:board_id/manage', :action => 'manage'
	    bw_views.connect 'projects/:project_id/boards/:board_id/manage_topic', :action => 'manage_topic'
    end
    bw_routes.with_options :conditions => {:method => :post} do |bw_views|
	    bw_views.connect 'projects/:project_id/boards/:board_id/manage', :action => 'manage'
	    bw_views.connect 'projects/:project_id/boards/:board_id/manage_topic', :action => 'manage_topic'
    end
  end
end
