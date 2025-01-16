Rails.application.routes.draw do
  root 'welcome#index'
  
  # Authentication routes
  get 'signup', to: 'users#new'
  post 'signup', to: 'users#create'
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  
  # Game routes
  get "/game", to: "game#show", as: :game
  post "/train", to: "game#train", as: :train
  post "/rest", to: "game#rest", as: :rest
  post "/reset", to: "game#reset", as: :reset
end