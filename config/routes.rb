Certotrack::Application.routes.draw do
  root to: 'certotrack#home'

  resources :sessions, only: [:create, :destroy, :signed_in]
  match '/signed_in', to: 'sessions#signed_in'

  match '/login', to: 'sessions#new', :via => [:get]

  #do I need :delete?
  match '/logout', to: 'sessions#destroy', :via => [:get, :delete]
end
