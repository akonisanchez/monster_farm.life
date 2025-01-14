# This file tells our game which web addresses go to which parts of our game
# Think of it like a map that tells visitors where to go
Rails.application.routes.draw do
  # When someone visits the homepage ('/'), show them the game
  root "game#show"

  # Set up addresses for different game actions
  get "/game", to: "game#show", as: :game    # Show the game screen
  post "/train", to: "game#train", as: :train # Handle training actions
  post "/rest", to: "game#rest", as: :rest    # Handle resting
  post "/reset", to: "game#reset", as: :reset # Reset the game
end