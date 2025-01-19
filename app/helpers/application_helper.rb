module ApplicationHelper
    def monster_image(monster)
      case monster.name
      when "Chocobat"
        "choco_bat.gif"
      when "Flopower"
        "flopower.gif"
      when "Galoot"
        "Galoot.gif"
      when "Pompador"
        "pompador.gif"
      when "Enoki"
        "enoki.gif"
      when "Shinka"
        "shinka.gif"
      end
    end
end
