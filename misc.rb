require './pokemon'
require './entityloader'

module PokeSky

  # Return the Pokemon game, given an ID.
  # TODO: The performance of Hash#keys *might* be bad. Check doc sometime.
  def name_for_id(id)
    @el.expr['pokemon'].keys[id - 1]
  end

  # Calculate the move power for a move.
  def move_power(move)
    @el.expr['attacks'].each do |type, attacks|
      if attacks.include?(move)
        idx = @el.expr['attacks'][type].index(move)
        idx /= 2.0 if type == 'Normal'
        return ((110 * Math.log10(idx.to_f / 2 + 1)) + 1).ceil # 170
      end
    end
  end

  # Return the move type of a move.
  def move_type(move)
    @el.expr['attacks'].each do |type, attacks|
      return type if attacks.include?(move)
    end
  end

  # Return the ID of a type.
  def type_id(type)
    @el.expr['types'].index(type)
  end

  # Calculate the attack multiplier of a move, given the attack type
  # and the two types of the defending Pokemon.
  def attack_multiplier(atk_type, def_prim, def_sec)
    mul = @el.expr['type_x'][atk_type][type_id(def_prim)]
    mul *= @el.expr['type_x'][atk_type][type_id(def_sec)] if def_sec
    mul
  end

  # Calculate attack bonus, given a Pokemon's level.
  def attack_bonus(lv)
    (110 * 3 * lv.to_f + 250) / 100 + 5
  end

  # Calculate defense bonus, given a Pokemon's level.
  def defense_bonus(lv)
    (70 * 3 * lv.to_f / 2 + 250) / 100 + 5
  end

  # Calculate the damage for a given move and attacking and defending Pokemon.
  def calculate_hit(move, attacker, defender)
    type = move_type(move)
    base_pwr = move_power(move)
    atk_mul = attack_multiplier(type, defender.type.prim, defender.type.sec)
    stab = (type == attacker.type.prim || type == attacker.type.sec) ? 1.5 : 1

    # TODO: Critical hits.
    cr = 1

    atk_bonus = attack_bonus(attacker.level)
    def_bonus = defense_bonus(defender.level)

    r = rand(85...100)
    base_dmg = (((attacker.level * 2 / 5.0 + 2) *
                 base_pwr * atk_bonus / 50 / def_bonus + 2) *
                cr * r / 100 * stab * atk_mul)

    # TOOD: Check levitate, fire absorb, water absorb, volt absorb,
    # sap sipper, etc.

    # Handle wonderguard mode.
    return 0 unless atk_mul > 1 if @modes.include?(:wonderguard)

    base_dmg.round
  end

end
