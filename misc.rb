require './pokemon'
require './entityloader'

module PokeSky

  IMMUNITY_ABILITIES = {
    'Levitate' => 'Ground',
    'Water Absorb' => 'Water',
    'Fire Absorb' => 'Fire',
    'Volt Absorb' => 'Electric',
    'Sap Sipper' => 'Grass'
  }

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
        return ((120 * Math.log10((idx + 1).to_f / 2 + 1)) + 1).ceil # 170
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

  # Calculate the basic single type multiplier.
  def type_multiplier(atk_type, def_type)
    mul = @el.expr['type_x'][atk_type][type_id(def_type)]

    # Handle inverse battles.
    @modes.include?(:inverse) ? 1.0 / (mul.zero? ? 0.5 : mul) : mul
  end

  # Calculate the attack multiplier of a move, given the attack type
  # and the two types of the defending Pokemon.
  def attack_multiplier(atk_type, def_prim, def_sec)
    mul = type_multiplier(atk_type, def_prim)
    mul *= type_multiplier(atk_type, def_sec) if def_sec
    mul
  end

  # Calculate attack bonus, given a Pokemon's level.
  def attack_bonus(lv)
    (110 * 3 * lv.to_f + 250) / 100 + 5
  end

  # Calculate defense bonus, given a Pokemon's level.
  def defense_bonus(lv)
    (80 * 3 * lv.to_f / 2 + 250) / 100 + 5
  end

  # Check whether the defending Pokemon has an ability that will
  # make it immune to the attack.
  def immune_from_ability?(move, defender)
    IMMUNITY_ABILITIES.each do |ability, type|
      in_grp = @el.expr['abilities'][ability].include?(defender.id)
      mv_has_type = type == move_type(move)
      return true if in_grp && mv_has_type
    end
    false
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

    r = rand(85...100) / 100.0
    mod = stab * atk_mul * cr * r
    # base_dmg = (((attacker.level * 2 / 5.0 + 2) *
    #              base_pwr * atk_bonus / 50 / def_bonus + 2) *
    #             cr * r / 100 * stab * atk_mul)
    base_dmg = ((2 * attacker.level + 10) / 250.0 *
                (atk_bonus / def_bonus) * base_pwr + 2) * mod

    # TOOD: Check levitate, fire absorb, water absorb, volt absorb,
    # sap sipper, etc.
    return 0 if immune_from_ability?(move, defender)

    # Handle wonderguard mode.
    return 0 unless atk_mul > 1 if @modes.include?(:wonderguard)

    base_dmg.round
  end

end
