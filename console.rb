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

require './pokemon'
require './generator'
require './entityloader'
require './player'

module PokeSky

  def disp_party(plr)
    puts "#{plr.name}'s Party:"
    plr.party.each do |pkmn|
      name = name_for_id(pkmn.id)
      prim, sec = @el.expr['pokemon'][name]
      moves = pkmn.moves.join(', ')

      puts "#{name} (#{prim}#{sec ? ', ' << sec : ''}) - #{moves}"
    end
    puts
  end

  def disp_battlers(plr)
    battler_names = plr.battlers.map { |b| b.name }.join(', ')
    puts "#{plr.name}'s Battlers: #{battler_names}"
  end

  # This should be refactored.
  def create_battlers(plr)
    plr.party.map do |pkmn|
      BattlePokemon.new(pkmn.owner, pkmn.id, pkmn.name, pkmn.xp,
                        pkmn.moves, pkmn.type)
    end
  end

  def console_start

    puts "Welcome to PokeSky!"

    plr = Player.new('Whac')
    random_party(plr)

    npc = Player.new('Hargrees')
    random_party(npc)

    disp_party(plr)
    disp_party(npc)

    plr.battlers = create_battlers(plr)
    npc.battlers = create_battlers(npc)

    # These represent the players.
    offense = plr
    defense = npc

    puts "It's a battle between #{offense.name} and #{defense.name}! Let's go!"

    auto = false
    # Start the battle loop.
    while true

      # If 'auto' mode (see above) is set to true, type RET to
      # progress through each player's turn.
      if auto
        sleep 2
      else
        gets
      end

      # These represent the Pokemon.
      attacker = offense.battlers[0]
      defender = defense.battlers[0]

      puts "#{offense.name}'s #{attacker.name} - #{attacker.health} HP"
      puts "#{defense.name}'s #{defender.name} - #{defender.health} HP"
      puts "It's #{attacker.name}'s turn!"

      move = attacker.moves.sample
      hit = calculate_hit(move, attacker, defender)

      puts "#{attacker.name}'s #{move} deals #{hit} damage to #{defender.name}!"
      effect = effect_desc(attack_multiplier(move_type(move),
                                             defender.type.prim,
                                             defender.type.sec))
      puts "It's #{effect}."

      defender.health -= hit
      if defender.health <= 0
        puts "#{offense.name}'s #{defender.name} fainted!"
        defense.battlers.delete(defender)
        disp_battlers(offense)
        disp_battlers(defense)
      end

      if defense.battlers.length.zero?
        puts "#{defense.name} has been defeated! The winner is #{offense.name}!"
        break
      end

      puts if auto
      offense, defense = defense, offense
    end

  end

end
