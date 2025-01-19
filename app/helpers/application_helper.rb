module ApplicationHelper
    def monster_image(monster)
      case monster.name
      when "Chocobat"
        "choco_bat.gif"
      when "Flopower"
        "flopower.gif"
      when "Galoot"
        "Galoot.gif"
      end
    end
end
