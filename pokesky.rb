require 'json'

module PokeSky

  class Player

    MAX_PARTY = 6

    attr :name, :party

    def initialize(name, party=[])
      @name = name
      @party = party
    end

    def has_party_space?
      return party.length < MAX_PARTY
    end

  end

  class Pokemon

    MAX_LEVEL = 100
    XP_RATE = 500

    attr :owner, :id, :xp, :moves

    def initialize(owner, id, xp, moves)
      @owner = owner
      @id = id
      @xp = xp
      @moves = moves
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

  class Type

    attr :prim, :sec

    def initialize(prim, sec)
      @prim = prim
      @sec = sec
    end

  end

  class DataHandler

    PATH = './data.json'

    def initialize
      load_defaults(:movepools)
    end

    private

    def load_defaults(which)
      expr = nil
      File.open(PATH) do |f|
        data = f.readlines.map { |s| s.strip }.join
        expr = JSON.parse(data)
      end

      if not expr
        raise "The file at '#{PATH}' was unable to be parsed."
        return
      end

      case which
      when :movepools
        p expr['special_pokemon']['legendary']
        p expr['movepools']['Pikachu']
      end
    end

  end

  class Test

    def initialize
      # pi = Pokemon.new('Whac', 25, Pokemon.xp_for_level(5),
      #                  ['Splash', 'Ember', 'Surf', 'Ice Beam'])
      # p pi

      # p Pokemon.xp_for_level(100)
      # p Pokemon.level_for_xp(pi.xp)
      # p pi.level

      # p = Player.new('Whac')
      # p p

      DataHandler.new
    end

  end

end

PokeSky::Test.new
