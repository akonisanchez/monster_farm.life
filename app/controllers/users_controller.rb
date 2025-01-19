class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to monster_selection_path, notice: "Welcome to MonsterFarm.Life! Choose your monster."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # rubocop:disable Metrics/MethodLength
  def choose_monster
    type = params[:monster_type]
    case type
    when "chocobat"
      monster = current_user.create_monster(
        name: "Chocobat",
        power: 5,
        speed: 5,
        defense: 1,
        health: 1,
        tiredness: 0
      )
    when "flopower"
      monster = current_user.create_monster(
        name: "Flopower",
        power: 5,
        speed: 1,
        defense: 5,
        health: 1,
        tiredness: 0
      )
    when "galoot"
      monster = current_user.create_monster(
        name: "Galoot",
        power: 3,
        speed: 3,
        defense: 3,
        health: 3,
        tiredness: 0
      )
    when "pompador"
      monster = current_user.create_monster(
        name: "Pompador",
        power: 3,
        speed: 1,
        defense: 2,
        health: 2,
        tiredness: 0
      )
    when "enoki"
      monster = current_user.create_monster(
        name: "Enoki",
        power: 1,
        speed: 2,
        defense: 3,
        health: 5,
        tiredness: 0
      )
    when "shinka"
      monster = current_user.create_monster(
        name: "Shinka",
        power: 5,
        speed: 3,
        defense: 4,
        health: 2,
        tiredness: 0
      )
    end

    redirect_to game_path
  end
  # rubocop:enable Metrics/MethodLength
  private

  def user_params
    params.require(:user).permit(:username, :password, :password_confirmation)
  end
end
