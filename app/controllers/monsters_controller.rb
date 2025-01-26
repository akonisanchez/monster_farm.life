# This controller manages monster ownership actions,
# like storing in stable or swapping an active monster.

class MonstersController < ApplicationController
  before_action :require_user

  # Store the current active monster in the stable
  # (only if stable isn't full). If user ends up with none,
  # force them to choose a new monster at monster_selection_path.
  def store
    user = current_user
    monster = user.active_monster

    if monster.nil?
      flash[:alert] = "You don't have an active monster to store."
      redirect_to game_path and return
    end

    if user.stable_full?
      flash[:alert] = "Your stable is full! (max 2 monsters stored)"
      redirect_to game_path and return
    end

    # Clear user's active monster slot => now it's 'stored'
    user.update(active_monster_id: nil)
    flash[:notice] = "#{monster.name} was stored in your stable."

    # If user now has no monster at all, go pick a new one
    if user.needs_monster?
      redirect_to monster_selection_path
    else
      redirect_to game_path
    end
  end

  # Swap in one monster from the stable to become the active monster
  def swap
    user = current_user
    stable_monster = user.stable_monsters.find_by(id: params[:id])

    if stable_monster.nil?
      flash[:alert] = "That monster isn't in your stable!"
      redirect_to game_path and return
    end

    old_active = user.active_monster
    user.update(active_monster_id: stable_monster.id)

    flash[:notice] = if old_active
      "You swapped out #{old_active.name} for #{stable_monster.name}!"
    else
      "You brought #{stable_monster.name} out from the stable!"
    end

    redirect_to game_path
  end

  private

  # Require user login or redirect to login
  def require_user
    redirect_to login_path unless current_user
  end
end
