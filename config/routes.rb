Rails.application.routes.draw do
  root 'welcome#index'
  
  # Authentication routes
  get 'signup', to: 'users#new'
  post 'signup', to: 'users#create'
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  get 'monster_selection', to: 'users#monster_selection', as: :monster_selection
  post 'choose_monster', to: 'users#choose_monster'
  
  # Game routes
  get "/game", to: "game#show", as: :game
  post "/train", to: "game#train", as: :train
  post "/rest", to: "game#rest", as: :rest
  post 'monsters/store', to: 'monsters#store', as: 'store_monster'
  post 'monsters/swap/:id', to: 'monsters#swap', as: 'swap_monster'
  get 'lab', to: 'users#lab', as: 'lab'
  get '/leaderboard', to: 'game#leaderboard', as: :leaderboard
end