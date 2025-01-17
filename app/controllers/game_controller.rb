# This is the main controller for our game
# It handles all the game actions like training and resting
class GameController < ApplicationController
  before_action :require_user
  before_action :get_monster

  def show
    redirect_to monster_selection_path unless @monster
    if @monster.tiredness >= 10
      @monster.destroy # Delete the exhausted monster
      render :game_over
    else
      render :show
    end
  end

  def train
    result = @monster.train(params[:drill])
    if result.is_a?(Hash) # Training succeeded with stat changes
      flash[:notice] = "Training successful!"
      flash[:stat_changes] = result
    else
      flash[:alert] = "Training failed..."
    end
    redirect_to game_path
  end

  def rest
    if @monster.tiredness.zero?
      flash[:alert] = "#{@monster.name} is already well rested!"
    else
      @monster.rest
      flash[:notice] = "#{@monster.name} took a rest"
    end
    redirect_to game_path
  end

  private

  def get_monster
    @monster = current_user.monster
    redirect_to monster_selection_path unless @monster
  end
end
