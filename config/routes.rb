ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
   map.root :controller => "home"
#   map.root :controller => "account", :action=>'login'
#   map.connect 'account/edit:js'

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action.:format'
#  map.connect '/expert/get_expert_image/:expert_id', :controller => 'expert', :action => 'get_expert_image' ,:expert_id=>/\d+/  
  map.connect 'approve_user',:controller => 'account', :action => 'approve_user'
  map.connect 'volunteer_for_schedule.js',:controller => 'schedule', :action => 'volunteer_for_schedule'
#  map.connect 'view_volunteers_for_this_schedule.js',:controller => 'schedule', :action => 'view_volunteers_for_this_schedule'
  map.connect 'view_volunteers_for_this_schedule.html',:controller => 'schedule', :action => 'view_volunteers_for_this_schedule'
  map.connect 'view_volunteers_for_this_schedule',:controller => 'schedule', :action => 'view_volunteers_for_this_schedule'
  map.connect 'invite_docs.js',:controller => 'invitation', :action => 'invite_docs'
  map.connect 'invite_this_doc.js',:controller => 'invitation', :action => 'invite_this_doc'
  map.connect 'approve_reject_this_doc.js',:controller => 'invitation', :action => 'approve_reject_this_doc'
  
  map.connect 'recieve_sms',:controller => 'invitation', :action => 'recieve_sms'
  map.connect 'recieve_sms_from_sms2mint_web',:controller => 'invitation', :action => 'recieve_sms_from_sms2mint'
  

  #This is for the Home Controllers
  map.connect 'home',:controller => 'home', :action => 'index'
  



end
