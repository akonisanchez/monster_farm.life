# This is the main controller for our game
# It handles all the game actions like training and resting
class GameController < ApplicationController
    before_action :get_monster

    def show
      if @monster.tiredness >= 10
        render :game_over
      else
        render :show
      end
    end

    def train
      success = @monster.train(params[:drill])
      flash[:notice] = if success
        "Training successful!"
      else
        "Training failed..."
      end
      redirect_to game_path
    end

    def rest
      if @monster.tiredness.zero?
        flash[:alert] = "Chocobat is already well rested!"
      else
        @monster.rest
        flash[:notice] = "Chocobat took a rest"
      end
      redirect_to game_path
    end

    def reset
      if @monster
        @monster.update(
          power: 1,
          speed: 1,
          defense: 1,
          health: 1,
          tiredness: 0
        )
        flash[:notice] = "Game reset! Good luck!"
      end
      redirect_to game_path
    end

    private

    def get_monster
      @monster = Monster.find_or_create_by(name: "Chocobat") do |monster|
        monster.power = 1
        monster.speed = 1
        monster.defense = 1
        monster.health = 1
        monster.tiredness = 0
      end
    end
end
