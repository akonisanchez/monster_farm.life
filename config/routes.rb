Rails.application.routes.draw do
  root 'welcome#index'
  get "/game", to: "game#show", as: :game
  post "/train", to: "game#train", as: :train
  post "/rest", to: "game#rest", as: :rest
  post "/reset", to: "game#reset", as: :reset
end
