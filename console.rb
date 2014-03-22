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

  def disp_battlers(plr, verbose=false)
    if verbose
      puts "#{plr.name}'s Battlers:"
      plr.battlers.each_with_index do |pkmn, slot|
        name = name_for_id(pkmn.id)

        puts "[#{slot}]: #{name} (HP: #{pkmn.health})"
      end
    else
      battler_names = plr.battlers.map { |b| b.name }.join(', ')
      puts "#{plr.name}'s Battlers: #{battler_names}"
    end
  end

  # Return a description of the attack multiplier.
  def effect_desc(atk_mul)
    case atk_mul
    when 0
      'not effective'
    when 0.25
      'hardly effective'
    when 0.5
      'not very effective'
    when 1
      'normally effective'
    when 2
      'super effective'
    when 4
      'ultra effective'
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

    plr.create_battlers!
    npc.create_battlers!

    # These represent the players.
    offense = plr
    defense = npc

    puts "It's a battle between #{offense.name} and #{defense.name}! Let's go!"

    # Start the battle loop.
    while true

      # These represent the Pokemon.
      attacker = offense.battlers[0]
      defender = defense.battlers[0]

      puts "#{offense.name}'s #{attacker.name} (#{attacker.health} HP)"
      puts "#{defense.name}'s #{defender.name} (#{defender.health} HP)"
      puts "It's #{attacker.name}'s turn!"

      forfeit = nil
      switch = nil
      move = nil
      if offense == plr
        puts "Your #{attacker.name}'s moves:"
        attacker.moves.each_with_index do |m, slot|
          puts "[#{slot}]: #{m}"
        end

        valid = false
        while true
          puts "Commands: a [slot] (attack); s [slot] (switch); d (display)."
          print "> "

          cmd = gets
          if !cmd
            forfeit = true
            valid = true
          else
            cmd.strip!
          end

          if cmd =~ /^a (\d)+$/i
            slot = $1.to_i
            if slot >= 0 && slot < Pokemon::MOVES_SIZE
              move = attacker.moves[slot]
              valid = true
            else
              puts "Invalid slot."
            end
          end

          if cmd =~ /^s (\d+)$/i
            slot = $1.to_i
            if slot >= 0 && slot < offense.battlers.size &&
                offense.battlers.index(attacker) != slot
              switch = slot
              valid = true
            else
              puts "Invalid slot."
            end
          end

          if cmd =~ /^d$/i
            disp_battlers(plr, true)
          end

          break if valid
        end
      else
        sleep 1
      end

      break if forfeit

      if switch
        puts "#{attacker.name}, return! Go, #{offense.battlers[switch].name}!"
        curr_id = offense.battlers.index(attacker)
        offense.battlers[switch], offense.battlers[curr_id] =
          offense.battlers[curr_id], offense.battlers[switch]
      else
        move ||= attacker.moves.sample
        hit = calculate_hit(move, attacker, defender)

        puts "#{attacker.name}'s #{move} deals #{hit} damage to #{defender.name}!"
        effect = effect_desc(attack_multiplier(move_type(move),
                                               defender.type.prim,
                                               defender.type.sec))
        puts "It's #{effect}."

        defender.health -= hit
        if defender.health <= 0
          puts "#{defense.name}'s #{defender.name} fainted!"
          defense.battlers.delete(defender)
          disp_battlers(offense)
          disp_battlers(defense)
        end
      end

      if defense.battlers.length.zero?
        puts "#{defense.name} has been defeated! The winner is #{offense.name}!"
        break
      end

      puts
      offense, defense = defense, offense
    end

    offense.reset_battlers!
    defense.reset_battlers!

  end

end
