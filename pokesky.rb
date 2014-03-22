require 'json'
require './pokemon'

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

  # TODO: This is like a God object. Bad.
  class EntityLoader

    PATH = './data.json'

    attr_accessor :expr

    def initialize
     @expr = load_defaults
    end

    private

    def load_defaults
      expr = nil
      File.open(PATH) do |f|
        data = f.readlines.map { |s| s.strip }.join
        expr = JSON.parse(data)
      end

      if not expr
        raise "The file at '#{PATH}' was unable to be parsed."
        return nil
      end

      expr
    end

  end

  class Converter

    def initialize(el)
      @el = el
    end

    # TODO: The performance of Hash#keys *might* be bad. Check doc sometime.
    def name_for_id(id)
      @el.expr['pokemon'].keys[id - 1]
    end

    def move_power(move)
      @el.expr['attacks'].each do |type, attacks|
        if attacks.include?(move)
          idx = @el.expr['attacks'][type].index(move)
          idx /= 2.0 if type == 'Normal'
          return ((110 * Math.log10(idx.to_f / 2 + 1)) + 1).ceil # 170
        end
      end
    end

    def move_type(move)
      @el.expr['attacks'].each do |type, attacks|
        return type if attacks.include?(move)
      end
    end

    def type_id(type)
      @el.expr['types'].index(type)
    end

    def attack_multiplier(atk_type, def_prim, def_sec)
      mul = @el.expr['type_x'][atk_type][type_id(def_prim)]
      mul *= @el.expr['type_x'][atk_type][type_id(def_sec)] if def_sec
      mul
    end

    def attack_bonus(lv)
      (110 * 3 * lv.to_f + 250) / 100 + 5
    end

    def defense_bonus(lv)
      (70 * 3 * lv.to_f / 2 + 250) / 100 + 5
    end

    def calculate_hit(move, attacker, defender)
      type = move_type(move)
      base_pwr = move_power(move)
      atk_mul = attack_multiplier(type, defender.type.prim, defender.type.sec)
      stab = (type == attacker.type.prim || type == attacker.type.sec) ? 1.5 : 1

      # TODO: Critical hits.
      cr = 1

      atk_bonus = attack_bonus(attacker.level)
      def_bonus = defense_bonus(defender.level)

      r = rand(85...100)
      base_dmg = (((attacker.level * 2 / 5.0 + 2) *
                   base_pwr * atk_bonus / 50 / def_bonus + 2) *
                  cr * r / 100 * stab * atk_mul)

      # TOOD: Check levitate, fire absorb, water absorb, volt absorb,
      # sap sipper, etc.

      base_dmg.round
    end

  end

  class Test

    def random_party(el, conv, plr)
      6.times do |n|
        id = rand(el.expr['movepools'].length) + 1
        name = conv.name_for_id(id)
        moves = el.expr['movepools'][name]
        if moves.length > Pokemon::MOVES_SIZE
          moves = moves[0..(Pokemon::MOVES_SIZE - 2)] <<
            moves[(Pokemon::MOVES_SIZE - 1)..-1].sample
        end
        pkmn = Pokemon.new(plr.name, id, name,
                           Pokemon.xp_for_level(100), moves,
                           Type.new(el.expr['pokemon'][name][0],
                                    el.expr['pokemon'][name][1]))
        plr.party << pkmn
      end
    end

    def initialize

      # p Pokemon.xp_for_level(100)
      # p Pokemon.level_for_xp(pi.xp)
      # p pi.level

      # p = Player.new('Whac')
      # p p

      el = EntityLoader.new
      conv = Converter.new(el)

      plr = Player.new('Whac')
      random_party(el, conv, plr)

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
        name = conv.name_for_id(pkmn.id)
        prim, sec = el.expr['pokemon'][name]

        puts "#{name} (#{prim}#{sec ? ', ' << sec : ''})"
        puts pkmn.moves.join(', ')
        puts
      end

      attacker = plr.party[0]
      defender = plr.party[1]
      move = attacker.moves[0]
      hit = conv.calculate_hit(move, attacker, defender)

      puts "#{attacker.name}'s #{move} deals #{hit} damage to #{defender.name}!"

      # p [
      #    conv.move_power('Aura Sphere'),
      #    conv.move_power('Earthquake'),
      #    conv.move_power('Splash'),
      #    conv.move_power('Last Resort'),
      #    conv.move_power('Megahorn')
      #   ]

      # ["Tail Glow", "Leech Life", "String Shot", "Pin Missile", "Bug Tackle", "Beez Buzz", "Fury Cutter", "Bug Bite", "Silver Wind", "U-Turn", "Signal Beam", "X-Scissor", "Bug Buzz", "Megahorn"].each do |name|
      #   puts "#{name} => #{conv.move_power(name)}"
      # end

      # ["Supersonic", "Screech", "Tickle", "Pound", "Scratch", "Tackle", "Fury Swipes", "Quick Attack", "Swift", "Headbutt", "Slash", "Retaliation", "Hyper Fang", "Body Slam", "Extremespeed", "Slam", "Spike Cannon", "Mega Kick", "Mega Punch", "Skull Bash", "Take Down", "Thrash", "Return", "Double Edge", "Last Resort", "Giga Impact", "Hyper Beam", "Explosion"].each do |name|
      #   puts "#{name} => #{conv.move_power(name)}"

      # end

      # puts [
      #       conv.attack_multiplier('Fire', 'Water', nil),
      #       conv.attack_multiplier('Fire', 'Water', 'Grass'),
      #       conv.attack_multiplier('Ghost', 'Normal', 'Flying'),
      #       conv.attack_multiplier('Normal', 'Ghost', 'Dark'),
      #       conv.attack_multiplier('Bug', 'Psychic', 'Dark'),
      #       conv.attack_multiplier('Bug', 'Fire', 'Poison'),
      #       ]
    end

  end

end

PokeSky::Test.new
