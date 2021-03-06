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

require 'rainbow'

require './pokemon'
require './generator'
require './entityloader'
require './player'
require './misc'

module PokeSky

  SLEEP_TIME = 2
  NPC_SWITCH_CHANCE = 8

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

  def color(s, col)
    # case type
    # when 'Bug' then GREEN
    # when 'Dark', 'Steel' then BLACK
    # when 'Dragon' then DARKBLUE
    # when 'Electric', 'Ground' then YELLOW
    # when 'Fighting', 'Rock' then BROWN
    # when 'Fire' then DARKRED
    # when 'Flying', 'Normal' then WHITE
    # when 'Ghost', 'Poison' then PURPLE
    # when 'Grass' then DARKGREEN
    # when 'Ice' then CYAN
    # when 'Psychic' then MAGENTA
    # when 'Water' then BLUE
    # else DARKCYAN
    # end
    Rainbow(s).color(col)
  end

  # ayy lmao
  def type_col(type)
    @el.expr['type_colors'][type_id(type)]
  end

  def type_colored(type)
    # "#{color(type)}#{type}#{RESET}"
    color(type, type_col(type))
  end

  def move_colored(move)
    # "#{color(move_type(move))}#{move}#{RESET}"
    color(move, type_col(move_type(move)))
  end

  def pkmn_colored(pkmn)
    # "#{color(pkmn.type.prim)}#{pkmn.name}#{RESET}"
    color(pkmn.name, type_col(pkmn.type.prim))
  end

  def sdisp_generic(group)
    buf = []
    group.each_with_index do |pkmn, n|
      prim, sec = pkmn.type.prim, pkmn.type.sec
      moves = pkmn.moves.map { |s| move_colored(s) }.join(', ')

      name_c = pkmn_colored(pkmn)
      s = [prim, sec].compact.map { |t| type_colored(t) }.join(', ')
      buf << "[#{n + 1}] #{name_c} %s(#{s}) - #{moves}"
    end
    buf
  end

  def disp_party(plr)
    puts "#{plr.name}'s Party:"
    sdisp_generic(plr.party).each do |line|
      printf(line, '')
      puts
    end
  end

  def disp_battlers(plr, verbose=false)
    if verbose
      puts "#{plr.name}'s Battlers:"
      sdisp_generic(plr.battlers).each_with_index do |line, n|
        pkmn = plr.battlers[n]
        printf(line, "(HP: #{pkmn.health}) ")
        puts
      end
    else
      battler_names = plr.battlers.map { |b| pkmn_colored(b) }.join(', ')
      puts "#{plr.name}'s Battlers: #{battler_names}"
    end
  end

  # Return a description of the attack multiplier.
  def effect_desc(atk_mul, immune=false)
    # Check for wonderguard.
    if @modes.include?(:wonderguard) && atk_mul <= 1
      return "#{BLACK}not effective#{RESET}"
    end

    # Check for immunity abilities.
    return "#{BLACK}not effective#{RESET}" if immune

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
    @modes ||= []
    mode_table = {
      '-d' => :delta,
      '-i' => :inverse,
      '-w' => :wonderguard
    }
    ARGV.each do |arg|
      if mode = mode_table[arg]
        @modes << mode
      end
    end
    @modes.uniq!

    mode_str = 'Modes: ' << @modes.map { |s|
      "#{WHITE}#{s.to_s.capitalize}#{RESET}"
    }.join(', ')
    puts "Welcome to PokeSky! #{mode_str}"

    group = 'powerful' # random_group
    puts "The group is: #{WHITE}#{group.capitalize}#{RESET}."

    plr = Player.new('Whac')
    random_party(plr, group)

    npc = Player.new('Hargrees')
    random_party(npc, group)

    puts "It's a battle between #{plr.name} and #{npc.name}! Let's go!"

    disp_party(plr)
    puts
    disp_party(npc)
    puts

    plr.create_battlers!
    npc.create_battlers!

    # These represent the players.
    offense = plr
    defense = npc

    # Start the battle loop.
    while true

      sleep SLEEP_TIME

      # These represent the Pokemon.
      attacker = offense.battlers[0]
      defender = defense.battlers[0]

      print "#{offense.name}'s #{pkmn_colored(attacker)} (#{attacker.health} HP) "
      puts "vs #{defense.name}'s #{pkmn_colored(defender)} (#{defender.health} HP)"
      # puts "It's #{pkmn_colored(attacker)}'s turn!"

      # I'm pretty sure there's a better way to do this.
      forfeit = nil
      switch = nil
      move = nil
      if offense == plr
        # puts "Your #{pkmn_colored(attacker)}'s moves:"
        attacker.moves.each_with_index do |m, slot|
          puts "[#{slot + 1}] #{move_colored(m)}"
        end

        # Loop until a valid command is given.
        valid = false
        while true
          puts "Commands: a [n] (attack); s [n] (switch); d (disp); e (enemy)."
          print "#{BLUE}>#{RESET} "

          cmd = $stdin.gets
          if !cmd
            forfeit = true
            valid = true
          else
            cmd.strip!
          end

          if cmd =~ /^a (\d)+$/i
            slot = $1.to_i - 1
            if slot >= 0 && slot < Pokemon::MOVES_SIZE
              move = attacker.moves[slot]
              valid = true
            else
              puts "Invalid slot."
            end
          end

          if cmd =~ /^s (\d+)$/i
            slot = $1.to_i - 1
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

          if cmd =~ /^e$/i
            disp_battlers(npc, true)
          end

          break if valid
        end
      else
        # Add a chance of dumb NPC switching.
        if rand(NPC_SWITCH_CHANCE).zero?
          valid_switches = offense.battlers.dup
          valid_switches.shift
          switch = offense.battlers.index(valid_switches.sample)
        end
      end

      break if forfeit

      # TODO: Pokemon selection after one fainting.
      if switch
        old_name_c = pkmn_colored(attacker)
        new_name_c = pkmn_colored(offense.battlers[switch])
        puts "#{old_name_c}, return! Go, #{new_name_c}!"

        curr_id = offense.battlers.index(attacker)
        offense.battlers[switch], offense.battlers[curr_id] =
          offense.battlers[curr_id], offense.battlers[switch]
      else
        move ||= attacker.moves.sample
        hit = calculate_hit(move, attacker, defender)

        name_c = pkmn_colored(attacker)
        mv_c = move_colored(move)
        def_name_c = pkmn_colored(defender)
        puts "#{name_c}'s #{mv_c} deals #{hit} damage to #{def_name_c}!"
        effect = effect_desc(attack_multiplier(move_type(move),
                                               defender.type.prim,
                                               defender.type.sec),
                             immune_from_ability?(move, defender))
        puts "It's #{effect}."

        defender.health -= hit
        if defender.health <= 0
          puts "#{defense.name}'s #{pkmn_colored(defender)} fainted!"
          defense.battlers.delete(defender)
          # disp_battlers(offense)
          # disp_battlers(defense)
          fainted = true
        end
      end

      if defense.battlers.length.zero?
        disp_battlers(offense)
        disp_battlers(defense)
        puts "#{defense.name} has been defeated! The winner is #{offense.name}!"
        break
      else
        if fainted
          disp_battlers(defense)
          puts "#{defense.name} sent out #{pkmn_colored(defense.battlers[0])}!"
          fainted = false
        end
      end

      puts
      offense, defense = defense, offense
    end

    offense.reset_battlers!
    defense.reset_battlers!

  end

end
