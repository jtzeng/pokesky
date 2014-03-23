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

  BLACK = "\033[30;1m"
  RED = "\033[31;1m"
  DARKRED = "\033[31m"
  GREEN = "\033[32;1m"
  DARKGREEN = "\033[32m"
  YELLOW = "\033[33;1m"
  BROWN = "\033[33m"
  BLUE = "\033[34;1m"
  DARKBLUE = "\033[34m"
  MAGENTA = "\033[35;1m"
  PURPLE = "\033[35m"
  CYAN = "\033[36;1m"
  DARKCYAN = "\033[36m"
  WHITE = "\033[37;1m"
  RESET = "\033[0m"

  def color(type)
    case type
    when 'Bug'
      GREEN
    when 'Dark', 'Steel'
      BLACK
    when 'Dragon'
      DARKBLUE
    when 'Electric', 'Ground'
      YELLOW
    when 'Fighting', 'Rock'
      BROWN
    when 'Fire'
      DARKRED
    when 'Flying', 'Normal'
      WHITE
    when 'Ghost', 'Poison'
      PURPLE
    when 'Grass'
      DARKGREEN
    when 'Ice'
      CYAN
    when 'Psychic'
      MAGENTA
    when 'Water'
      BLUE
    else
      DARKCYAN
    end
  end

  def move_color(move)
    "#{color(move_type(move))}#{move}#{RESET}"
  end

  def type_color(type)
    "#{color(type)}#{type}#{RESET}"
  end

  def pkmn_color(pkmn)
    "#{color(pkmn.type.prim)}#{pkmn.name}#{RESET}"
  end

  def disp_party(plr)
    puts "#{plr.name}'s Party:"
    plr.party.each do |pkmn|
      prim, sec = @el.expr['pokemon'][pkmn.name]
      moves = pkmn.moves.map { |s| move_color(s) }.join(', ')

      s = sec ? ', ' << type_color(sec) : ''
      puts "#{pkmn_color(pkmn)} (#{type_color(prim)}#{s}) - #{moves}"
    end
    puts
  end

  def disp_battlers(plr, verbose=false)
    if verbose
      puts "#{plr.name}'s Battlers:"
      plr.battlers.each_with_index do |pkmn, slot|
        puts "[#{slot}]: #{pkmn_color(pkmn)} (HP: #{pkmn.health})"
      end
    else
      battler_names = plr.battlers.map { |b| pkmn_color(b) }.join(', ')
      puts "#{plr.name}'s Battlers: #{battler_names}"
    end
  end

  # Return a description of the attack multiplier.
  def effect_desc(atk_mul)
    case atk_mul
    when 0
      "#{BLACK}not effective#{RESET}"
    when 0.25
      "#{PURPLE}hardly effective#{RESET}"
    when 0.5
      "#{DARKGREEN}not very effective#{RESET}"
    when 1
      "#{WHITE}normally effective#{RESET}"
    when 2
      "#{YELLOW}super effective#{RESET}"
    when 4
      "#{RED}ultra effective#{RESET}"
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

      sleep 1

      # These represent the Pokemon.
      attacker = offense.battlers[0]
      defender = defense.battlers[0]

      print "#{offense.name}'s #{pkmn_color(attacker)} (#{attacker.health} HP) "
      puts "vs #{defense.name}'s #{pkmn_color(defender)} (#{defender.health} HP)"
      puts "It's #{pkmn_color(attacker)}'s turn!"

      forfeit = nil
      switch = nil
      move = nil
      if offense == plr
        puts "Your #{pkmn_color(attacker)}'s moves:"
        attacker.moves.each_with_index do |m, slot|
          puts "[#{slot}]: #{move_color(m)}"
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
      end

      break if forfeit

      if switch
        old_name_c = pkmn_color(attacker)
        new_name_c = pkmn_color(offense.battlers[switch])
        puts "#{old_name_c}, return! Go, #{new_name_c}!"

        curr_id = offense.battlers.index(attacker)
        offense.battlers[switch], offense.battlers[curr_id] =
          offense.battlers[curr_id], offense.battlers[switch]
      else
        move ||= attacker.moves.sample
        hit = calculate_hit(move, attacker, defender)

        name_c = pkmn_color(attacker)
        mv_c = move_color(move)
        def_name_c = pkmn_color(defender)
        puts "#{name_c}'s #{mv_c} deals #{hit} damage to #{def_name_c}!"
        effect = effect_desc(attack_multiplier(move_type(move),
                                               defender.type.prim,
                                               defender.type.sec))
        puts "It's #{effect}."

        defender.health -= hit
        if defender.health <= 0
          puts "#{defense.name}'s #{pkmn_color(defender)} fainted!"
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
