require './pokemon'
require './generator'
require './player'

module PokeSky

  # This doesn't actually test anything.
  def test

    p Pokemon.xp_for_level(100)
    p Pokemon.level_for_xp(pi.xp)
    p pi.level

    p = Player.new('Whac')
    p p

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
