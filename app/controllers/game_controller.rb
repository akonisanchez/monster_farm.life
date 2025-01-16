# This is the main controller for our game
# It handles all the game actions like training and resting
class GameController < ApplicationController
    before_action :get_monster

    def show
      render :game_over if @monster.tiredness >= 10
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
      @monster.rest
      flash[:notice] = "Scrappo took a rest"
      redirect_to game_path
    end

    def rest
        if @monster.tiredness.zero?
          flash[:alert] = "Scrappo is already well rested!"
        else
          @monster.rest
          flash[:notice] = "Scrappo took a rest"
        end
        redirect_to game_path
      end

    private

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
