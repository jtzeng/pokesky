require './pokemon'
require './misc'

module PokeSky

  # Generate a random Pokemon.
  def random_pokemon(plr)
    id = rand(@el.expr['movepools'].length) + 1
    name = name_for_id(id)
    moves = @el.expr['movepools'][name]

    if moves.length > Pokemon::MOVES_SIZE
      moves = moves[0..(Pokemon::MOVES_SIZE - 2)] <<
        moves[(Pokemon::MOVES_SIZE - 1)..-1].sample
    end

    return Pokemon.new(plr.name, id, name,
                       Pokemon.xp_for_level(100), moves,
                       Type.new(@el.expr['pokemon'][name][0],
                                @el.expr['pokemon'][name][1]))
  end

  # Generate a party of random Pokemon.
  def random_party(plr)
    Player::MAX_PARTY.times do |n|
      plr.party << random_pokemon(plr)
    end
  end

end
