Certotrack::Application.routes.draw do

  root to: 'certotrack#home'

  devise_for :users, path_names: {sign_in: "login", sign_out: "logout"}
  devise_scope :user do
    get '/users/logout' => 'devise/sessions#destroy'
    get "login", :to => "devise/sessions#new"
    get "logout", :to => "devise/sessions#destroy"
  end

  resources :equipment
  get 'expired_equipment', action: 'expired', controller: 'equipment'
  get 'expiring_equipment', action: 'expiring', controller: 'equipment'
  get 'noninspectable_equipment', action: 'noninspectable', controller: 'equipment'
  get 'search_equipment', action: 'search', controller: 'equipment'
  get 'ajax_assignee', action: 'ajax_assignee', controller: 'equipment'

  resources :certification_types
  get 'search_certification_types', action: 'search', controller: 'certification_types'

  resources :employees
  get '/deactivate_confirm/:id', to: 'employees#deactivate_confirm', as: 'deactivate_confirm'
  get '/deactivate/:id', to: 'employees#deactivate', as: 'deactivate'
end
