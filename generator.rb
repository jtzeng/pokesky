require './pokemon'
require './misc'

module PokeSky

  def random_group
    @el.expr['special_pokemon'].keys.sample
  end

  # Generate a random Pokemon.
  def random_pokemon(plr, group)
    id = @el.expr['special_pokemon'][group].sample
    name = name_for_id(id)
    moves = @el.expr['movepools'][name]

    if moves.length > Pokemon::MOVES_SIZE
      moves = moves[0..(Pokemon::MOVES_SIZE - 2)] <<
        moves[(Pokemon::MOVES_SIZE - 1)..-1].sample
    end

    prim, sec = @el.expr['pokemon'][name][0..1]
    # Handle delta mode.
    if @modes.include?(:delta)
      all_types = @el.expr['types'].dup
      prim = all_types.sample
      all_types.delete(prim)

      # Add more chance of having no secondary type.
      all_types += Array.new(5, nil)
      sec = all_types.sample
    end
    return Pokemon.new(plr.name, id, name,
                       Pokemon.xp_for_level(100), moves,
                       Type.new(prim, sec))
  end

  # Generate a party of random Pokemon.
  def random_party(plr, group)
    Player::MAX_PARTY.times do |n|
      plr.party << random_pokemon(plr, group)
    end
  end

end
