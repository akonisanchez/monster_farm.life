# This is the main controller for our game
# It handles all the game actions like training and resting
class GameController < ApplicationController
  before_action :require_user
  before_action :get_monster

  # Show the main game screen
  def show
    # If user has no active monster, send them to monster_selection_path (our "lab" placeholder)
    redirect_to monster_selection_path and return unless @monster

    # If monster is too tired, destroy it and render Game Over
    if @monster.tiredness >= 10
      @monster.destroy # Delete the exhausted monster
      render :game_over
    else
      # Gather recent logs to display
      @recent_logs = @monster.training_logs.order(created_at: :desc).limit(5)
      render :show
    end
  end

  # Train the monster using the chosen drill
  def train
    if @monster.nil?
      flash[:alert] = "No active monster to train!"
      redirect_to monster_selection_path and return
    end

    result = @monster.train(params[:drill])
    if result.is_a?(Hash) # Training succeeded with stat changes
      flash[:notice] = build_success_message
      flash[:stat_changes] = result
    else
      flash[:alert] = "Training failed..."
    end
    redirect_to game_path
  end

  # Rest the monster to reduce tiredness
  def rest
    if @monster.nil?
      flash[:alert] = "No active monster to rest!"
      redirect_to monster_selection_path and return
    end

    if @monster.tiredness.zero?
      flash[:alert] = "#{@monster.name} is already well rested!"
    else
      @monster.rest
      flash[:notice] = "#{@monster.name} took a rest"
    end
    redirect_to game_path
  end

  # Show leaderboard
  def leaderboard
    @leaderboard = User.ranked.limit(5) # Top 5 users
  end

  private

  # This gets the user's active monster for game actions
  def get_monster
    @monster = current_user.active_monster
  end

  # Build success message including any special training events
  def build_success_message
    messages = [ "Training successful!" ]

    if @monster.feeling_good
      messages << "#{@monster.name} is feeling good! Next training will be more potent!"
    elsif @monster.hot_streak && @monster.training_streak == 5
      messages << "#{@monster.name} is on a hot streak! #{@monster.name} looks motivated!"
    end

    messages.join(" ")
  end

  # For building a more detailed training message if needed
  def build_training_message
    current_hour = Time.current.in_time_zone(current_user.timezone).hour
    bonus_message = case current_hour
    when 6..11
      "Morning power training bonus active!"
    when 12..17
      "Afternoon speed training bonus active!"
    when 18..23
      "Evening defense training bonus active!"
    else
      "Night health training bonus active!"
    end

    "Training successful! #{bonus_message}"
  end

  # This requires a user to be logged in, else redirect
  def require_user
    redirect_to login_path unless current_user
  end
end
