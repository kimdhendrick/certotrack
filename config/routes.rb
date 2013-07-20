Certotrack::Application.routes.draw do
  root to: 'certotrack#home'

  resources :sessions, only: [:create, :destroy, :signed_in]
  match '/signed_in', to: 'sessions#signed_in'
  match '/logout', to: 'sessions#destroy', :via => [:get, :delete]
  match '/login', to: 'certotrack#welcome', :via => [:get]
end
