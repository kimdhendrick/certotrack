Certotrack::Application.routes.draw do
  resources :equipment

  devise_for :users, path_names: {sign_in: "login", sign_out: "logout"}
  devise_scope :user do
    get '/users/logout' => 'devise/sessions#destroy'
    get "login", :to => "devise/sessions#new"
    get "logout", :to => "devise/sessions#destroy"
  end

  root to: 'certotrack#home'
end
