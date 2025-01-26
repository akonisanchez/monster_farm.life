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
      monster = current_user.monsters.create(
        name: "Chocobat",
        power: 25,
        speed: 35,
        defense: 20,
        health: 20,
        tiredness: 0
      )
    when "flopower"
      monster = current_user.monsters.create(
        name: "Flopower",
        power: 30,
        speed: 15,
        defense: 35,
        health: 20,
        tiredness: 0
      )
    when "galoot"
      monster = current_user.monsters.create(
        name: "Galoot",
        power: 33,
        speed: 33,
        defense: 33,
        health: 33,
        tiredness: 0
      )
    when "pompador"
      monster = current_user.monsters.create(
        name: "Pompador",
        power: 22,
        speed: 28,
        defense: 20,
        health: 30,
        tiredness: 0
      )
    when "enoki"
      monster = current_user.monsters.create(
        name: "Enoki",
        power: 15,
        speed: 10,
        defense: 30,
        health: 45,
        tiredness: 0
      )
    when "shinka"
      monster = current_user.monsters.create(
        name: "Shinka",
        power: 30,
        speed: 40,
        defense: 15,
        health: 15,
        tiredness: 0
      )
    end

    current_user.update(active_monster_id: monster.id)

    redirect_to game_path
  end
  # rubocop:enable Metrics/MethodLength

  private

  def user_params
    params.require(:user).permit(:username, :password, :password_confirmation)
  end
end
