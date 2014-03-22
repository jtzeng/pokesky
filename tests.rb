require './pokemon'
require './generator'
require './player'
require './misc'

module PokeSky

  # This doesn't actually test anything.
  def test

    # This is pretty bad "testing" code. Oh well, it works.
    # Check the Pokemon count.
    puts @el.expr['movepools'].length == @el.expr['pokemon'].length

    mvpl_pkmn = @el.expr['movepools'].keys
    all_pkmn = @el.expr['pokemon'].keys

    # Check the Pokemon names.
    puts all_pkmn == mvpl_pkmn
    p all_pkmn.reject { |name| mvpl_pkmn.include?(name) }
    p mvpl_pkmn.reject { |name| all_pkmn.include?(name) }

    # Check the types.
    puts @el.expr['types'] == @el.expr['attacks'].keys

    # Check the number of attacks per type.
    @el.expr['attacks'].each do |k, v|
      print "#{v.length}, "
    end
    puts

    # Check valid attacks.
    valid_attacks = @el.expr['attacks'].values.flatten
    @el.expr['movepools'].each do |k, v|
      v.each do |mv|
        if !valid_attacks.include?(mv)
          puts "#{k}: #{mv}"
        end
      end
    end

    p Pokemon.xp_for_level(100)
    p Pokemon.level_for_xp(Pokemon.xp_for_level(100))

    p [
       move_power('Aura Sphere'),
       move_power('Earthquake'),
       move_power('Splash'),
       move_power('Last Resort'),
       move_power('Megahorn')
      ]

    ["Tail Glow", "Leech Life", "String Shot", "Pin Missile", "Bug Tackle", "Beez Buzz", "Fury Cutter", "Bug Bite", "Silver Wind", "U-Turn", "Signal Beam", "X-Scissor", "Bug Buzz", "Megahorn"].each do |name|
      puts "#{name} => #{move_power(name)}"
    end

    ["Supersonic", "Screech", "Tickle", "Pound", "Scratch", "Tackle", "Fury Swipes", "Quick Attack", "Swift", "Headbutt", "Slash", "Retaliation", "Hyper Fang", "Body Slam", "Extremespeed", "Slam", "Spike Cannon", "Mega Kick", "Mega Punch", "Skull Bash", "Take Down", "Thrash", "Return", "Double Edge", "Last Resort", "Giga Impact", "Hyper Beam", "Explosion"].each do |name|
      puts "#{name} => #{move_power(name)}"

    end

    puts [
          attack_multiplier('Fire', 'Water', nil),
          attack_multiplier('Fire', 'Water', 'Grass'),
          attack_multiplier('Ghost', 'Normal', 'Flying'),
          attack_multiplier('Normal', 'Ghost', 'Dark'),
          attack_multiplier('Bug', 'Psychic', 'Dark'),
          attack_multiplier('Bug', 'Fire', 'Poison'),
         ]
  end

end
