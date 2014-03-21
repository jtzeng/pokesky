require 'json'

# TODO: Separate into classes.
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

  # TODO: This is like a God object. Bad.
  class DataHandler

    PATH = './data.json'

    attr_accessor :pokemon, :movepools, :attacks, :type_x

    def initialize
      load_defaults(:pokemon, :movepools, :attacks, :type_x)
    end

    # TODO: The performance of Hash#keys *might* be bad. Check doc sometime.
    def name_for_id(id)
      @pokemon.keys[id]
    end

    private

    def load_defaults(*which)
      expr = nil
      File.open(PATH) do |f|
        data = f.readlines.map { |s| s.strip }.join
        expr = JSON.parse(data)
      end

      if not expr
        raise "The file at '#{PATH}' was unable to be parsed."
        return
      end

      which.each do |kw|

        case kw
        when :pokemon
          @pokemon = expr['pokemon']

        when :movepools
          @movepools = expr['movepools']

        when :attacks
          @attacks = expr['attacks']

        when :type_x
          @type_multiplier = expr['type_x']

        end

        puts "Finished loading #{kw.to_s}..."

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

      data_handler = DataHandler.new
      plr = Player.new('Whac')
      6.times do |n|
        id = rand(data_handler.movepools.length) + 1
        name = data_handler.name_for_id(id)
        plr.party << Pokemon.new(plr.name, id, Pokemon.xp_for_level(5),
                                 data_handler.movepools[name])
      end

      # p plr.party

      plr.party.each do |pkmn|
        # TODO: HUGE problem with design here.
        # Is it better to store attrs like 'name' and 'type's
        # per Pokemon object, versus some 'database' object that
        # contains info for everything in the game?
        #
        # How will this interact with a future database system?
        #
        # Potential problems:
        # - Redundant
        # - Waste of memory
        #
        # Potential benefits:
        # - Might suit the db sys better.
        name = data_handler.name_for_id(pkmn.id)
        prim, sec = data_handler.pokemon[name]

        puts "#{name} (#{prim}#{sec ? ', ' << sec : ''})"
        puts pkmn.moves.join(', ')
        puts
      end

    end

  end

end

PokeSky::Test.new
