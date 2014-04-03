require './pokemon'

# Wouldn't "Trainer" be a better name? :P

module PokeSky

  class Player

    MAX_PARTY = 6

    attr_accessor :name, :party, :battlers

    def initialize(name, party=[])
      @name = name
      @party = party
      @battlers = nil
    end

    def has_party_space?
      return party.length < MAX_PARTY
    end

    # Clone the current Pokemon and give them battle attributes.
    def create_battlers!
      @battlers = @party.map do |pkmn|
        BattlePokemon.new(pkmn.owner, pkmn.id, pkmn.name, pkmn.xp,
                          pkmn.moves, pkmn.type)
      end
    end

    def reset_battlers!
      @battlers = nil
    end

  end

end
