module PokeSky

  class Type

    attr :prim, :sec

    def initialize(prim, sec)
      @prim = prim
      @sec = sec
    end

  end

  class Pokemon

    MAX_LEVEL = 100
    XP_RATE = 500
    MOVES_SIZE = 4

    attr :owner, :id, :name, :xp, :moves, :type

    def initialize(owner, id, name, xp, moves, type)
      @owner = owner
      @id = id
      @name = name
      @xp = xp
      raise "# of moves is not #{MOVES_SIZE}!" if moves.length != MOVES_SIZE
      @moves = moves
      @type = type
    end

    def level
      Pokemon.level_for_xp(@xp)
    end

    def self.cap_level(lv)
      lv > MAX_LEVEL ? MAX_LEVEL : lv
    end

    def self.xp_for_level(lv)
      cap_level(lv) * XP_RATE
    end

    def self.level_for_xp(xp)
      cap_level((xp.to_f / XP_RATE).floor)
    end

  end

  class BattlePokemon < Pokemon

    def initialize(owner, id, xp, moves)
      super
      @health = max_health
    end

    def max_health
      level * 4
    end

  end

end
