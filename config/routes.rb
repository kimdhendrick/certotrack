Certotrack::Application.routes.draw do

  get '/about_us', to: 'static_pages#about_us'
  get '/dashboard', to: 'certotrack#home'

  devise_for :users, path_names: {sign_in: "login", sign_out: "logout"}
  devise_scope :user do
    root 'devise/sessions#new'
    get '/users/logout' => 'devise/sessions#destroy'
    get "login", :to => "devise/sessions#new"
    get "logout", :to => "devise/sessions#destroy"
  end

  resource :change_password, only: [:edit] do
    collection do
      patch 'update_password'
    end
  end

  resources :equipment
  get 'expired_equipment', action: 'expired', controller: 'equipment'
  get 'expiring_equipment', action: 'expiring', controller: 'equipment'
  get 'noninspectable_equipment', action: 'noninspectable', controller: 'equipment'
  get 'search_equipment', action: 'search', controller: 'equipment'
  get 'ajax_assignee', action: 'ajax_assignee', controller: 'equipment'
  get 'ajax_equipment_name', action: 'ajax_equipment_name', controller: 'equipment'

  resources :certification_types do
    resources :auto_recertifications, only: [:new, :create]
  end
  get 'search_certification_types', action: 'search', controller: 'certification_types'
  get 'ajax_is_units_based', action: 'ajax_is_units_based', controller: 'certification_types'

  resources :employees

  get '/deactivate_confirm/:id', to: 'employee_deactivation#deactivate_confirm', as: 'deactivate_confirm'
  get '/deactivate/:id', to: 'employee_deactivation#deactivate', as: 'deactivate'
  get 'deactivated_employees', action: 'deactivated_employees', controller: 'employee_deactivation'

  resources :batch_certifications, only: [:create]
  resources :certifications do
    resources :recertifications, only: [:new, :create]
  end
  get '/certification_history/:id', to: 'certifications#certification_history', as: 'certification_history'
  get 'expired_certifications', action: 'expired', controller: 'certifications'
  get 'expiring_certifications', action: 'expiring', controller: 'certifications'
  get 'units_based_certifications', action: 'units_based', controller: 'certifications'
  get 'recertification_required_certifications', action: 'recertification_required', controller: 'certifications'
  get 'search_certifications', action: 'search', controller: 'certifications'

  resources :training_events, only: [:new, :create]
  get 'employee_list_training_event', action: 'list_employees', controller: 'training_events'
  get 'certification_type_list_training_event', action: 'list_certification_types', controller: 'training_events'

  resources :locations

  resources :vehicles
  get 'search_vehicles', action: 'search', controller: 'vehicles'
  get 'ajax_vehicle_make', action: 'ajax_vehicle_make', controller: 'vehicles'
  get 'ajax_vehicle_model', action: 'ajax_vehicle_model', controller: 'vehicles'

  resources :service_types

  get '/service_history/:id', to: 'services#service_history', as: 'service_history'
  resources :services, only: [:index, :new, :create, :show, :edit, :update, :destroy] do
    resources :reservices, only: [:new, :create]
  end
  get 'expired_services', action: 'expired', controller: 'services'
  get 'expiring_services', action: 'expiring', controller: 'services'

  resources :customers, only: [:new, :create, :show, :edit, :update, :index]

  resources :customer_users, controller: 'users', only: [:index, :show, :new, :create, :edit, :update, :destroy]
end
