Certotrack::Application.routes.draw do
  resources :equipment
  get 'expired_equipment', action: 'expired', controller: 'equipment'
  get 'expiring_equipment', action: 'expiring', controller: 'equipment'
  get 'noninspectable_equipment', action: 'noninspectable', controller: 'equipment'
  get 'ajax_assignee', action: 'ajax_assignee', controller: 'equipment'

  devise_for :users, path_names: {sign_in: "login", sign_out: "logout"}
  devise_scope :user do
    get '/users/logout' => 'devise/sessions#destroy'
    get "login", :to => "devise/sessions#new"
    get "logout", :to => "devise/sessions#destroy"
  end

  root to: 'certotrack#home'
end
