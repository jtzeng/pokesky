require './pokemon'
require './generator'
require './player'

module PokeSky

  # This doesn't actually test anything.
  def test

    # p Pokemon.xp_for_level(100)
    # p Pokemon.level_for_xp(pi.xp)
    # p pi.level

    # p = Player.new('Whac')
    # p p

    plr = Player.new('Whac')
    random_party(plr)

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
      name = name_for_id(pkmn.id)
      prim, sec = @el.expr['pokemon'][name]

      puts "#{name} (#{prim}#{sec ? ', ' << sec : ''})"
      puts pkmn.moves.join(', ')
      puts
    end

    attacker = plr.party[0]
    defender = plr.party[1]
    move = attacker.moves[0]
    hit = calculate_hit(move, attacker, defender)

    puts "#{attacker.name}'s #{move} deals #{hit} damage to #{defender.name}!"
    effect = effect_desc(attack_multiplier(move_type(move),
                                           defender.type.prim,
                                           defender.type.sec))
    puts "It's #{effect}."

    # p [
    #    move_power('Aura Sphere'),
    #    move_power('Earthquake'),
    #    move_power('Splash'),
    #    move_power('Last Resort'),
    #    move_power('Megahorn')
    #   ]

    # ["Tail Glow", "Leech Life", "String Shot", "Pin Missile", "Bug Tackle", "Beez Buzz", "Fury Cutter", "Bug Bite", "Silver Wind", "U-Turn", "Signal Beam", "X-Scissor", "Bug Buzz", "Megahorn"].each do |name|
    #   puts "#{name} => #{move_power(name)}"
    # end

    # ["Supersonic", "Screech", "Tickle", "Pound", "Scratch", "Tackle", "Fury Swipes", "Quick Attack", "Swift", "Headbutt", "Slash", "Retaliation", "Hyper Fang", "Body Slam", "Extremespeed", "Slam", "Spike Cannon", "Mega Kick", "Mega Punch", "Skull Bash", "Take Down", "Thrash", "Return", "Double Edge", "Last Resort", "Giga Impact", "Hyper Beam", "Explosion"].each do |name|
    #   puts "#{name} => #{move_power(name)}"

    # end

    # puts [
    #       attack_multiplier('Fire', 'Water', nil),
    #       attack_multiplier('Fire', 'Water', 'Grass'),
    #       attack_multiplier('Ghost', 'Normal', 'Flying'),
    #       attack_multiplier('Normal', 'Ghost', 'Dark'),
    #       attack_multiplier('Bug', 'Psychic', 'Dark'),
    #       attack_multiplier('Bug', 'Fire', 'Poison'),
    #      ]
  end

end
