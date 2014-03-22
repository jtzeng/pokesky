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

    # Return whether the player's party has available space.
    def has_party_space?
      return party.length < MAX_PARTY
    end

  end

end
