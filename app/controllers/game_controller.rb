# This is the main controller for our game
# It handles all the game actions like training and resting
class GameController < ApplicationController
    # Get our monster before doing anything
    before_action :get_monster
    
    # Show the main game page
    def show
      # If monster is too tired, show game over screen
      if @monster.tiredness >= 10
        render :game_over
      end
    end
    
    # This handles what happens when we click a training button
    def train
      success = @monster.train(params[:drill])
      flash[:notice] = if success
        "Training successful!"
      else
        "Training failed..."
      end
      redirect_to game_path
    end
    
    # This handles what happens when we click the rest button
    def rest
      @monster.rest
      flash[:notice] = "Scrappo took a rest"
      redirect_to game_path
    end
    
    # This resets the game when we want to start over
    def reset
      @monster.update(
        power: 1,
        speed: 1,
        defense: 1,
        health: 1,
        tiredness: 0
      )
      redirect_to game_path
    end
    
    private
    
    # This gets or creates our monster
    def get_monster
      @monster = Monster.find_or_create_by(name: "Scrappo") do |monster|
        monster.power = 1
        monster.speed = 1
        monster.defense = 1
        monster.health = 1
        monster.tiredness = 0
      end
    end
  end