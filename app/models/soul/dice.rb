# SOUL's open-ended 2d20 dice, ported from the SOUL plugin's dice engine.
#
# Roll two d20s and add them. Double 20 explodes: roll again and add, for as
# long as doubles keep coming. Double 1 implodes: roll again and subtract.
# A Boon or Bane modifier rerolls low (or high) dice; that arrives with Boons
# and Banes in a later step, so for now the modifier is always 0.
#
# .success_probability works out the exact chance, without rolling, so a
# result can be marked extraordinary when it was very unlikely.
module Soul::Dice
  DIE_MIN = 1
  DIE_MAX = 20
  MAX_BAND_SIZE = DIE_MAX - 1

  module_function

  # Returns { total:, mode: "normal"/"explosion"/"implosion", segments: [[d1, d2], ...] }.
  def roll(net_modifier = 0, random: Random)
    band = reroll_band(net_modifier)
    die = -> { random.rand(DIE_MIN..DIE_MAX) }
    first = [ die.call, die.call ]
    segments = [ first ]
    mode = "normal"
    if first == [ DIE_MAX, DIE_MAX ] || first == [ DIE_MIN, DIE_MIN ]
      mode = first[0] == DIE_MAX ? "explosion" : "implosion"
      loop do
        pair = [ die.call, die.call ]
        segments << pair
        break unless pair == first
      end
    end
    segments = segments.map { |pair| pair.map { |value| apply_reroll(value, band, die) } }

    total = segments.first.sum
    segments.drop(1).each { |pair| total += mode == "implosion" ? -pair.sum : pair.sum }
    { total: total, mode: mode, segments: segments }
  end

  # The exact chance that the dice alone reach needed.
  def success_probability(net_modifier, needed, depth: 12)
    total_pmf(net_modifier, depth).sum { |total, chance| total >= needed ? chance : 0.0 }
  end

  def total_pmf(net_modifier, depth = 12)
    contribution = die_contribution_pmf(reroll_band(net_modifier))
    pmf = {}
    each_die_pair do |d1, d2, weight|
      segment = convolve(contribution[d1], contribution[d2])
      if d1 == DIE_MAX && d2 == DIE_MAX
        merge_weighted!(pmf, convolve(segment, chain_pmf(DIE_MAX, contribution, depth - 1)), weight)
      elsif d1 == DIE_MIN && d2 == DIE_MIN
        merge_weighted!(pmf, convolve(segment, negate(chain_pmf(DIE_MIN, contribution, depth - 1))), weight)
      else
        merge_weighted!(pmf, segment, weight)
      end
    end
    pmf
  end

  def chain_pmf(trigger, contribution, depth)
    return { 0 => 1.0 } if depth <= 0
    pmf = {}
    each_die_pair do |d1, d2, weight|
      segment = convolve(contribution[d1], contribution[d2])
      segment = convolve(segment, chain_pmf(trigger, contribution, depth - 1)) if d1 == trigger && d2 == trigger
      merge_weighted!(pmf, segment, weight)
    end
    pmf
  end

  def each_die_pair
    weight = 1.0 / ((DIE_MAX - DIE_MIN + 1)**2)
    (DIE_MIN..DIE_MAX).each { |d1| (DIE_MIN..DIE_MAX).each { |d2| yield d1, d2, weight } }
  end

  def die_contribution_pmf(band)
    outside = (DIE_MIN..DIE_MAX).reject { |v| band&.cover?(v) }
    rerolled = outside.to_h { |v| [ v, 1.0 / outside.size ] }
    (DIE_MIN..DIE_MAX).to_h { |v| [ v, band&.cover?(v) ? rerolled : { v => 1.0 } ] }
  end

  def convolve(a, b)
    a.each_with_object(Hash.new(0.0)) { |(va, pa), out| b.each { |vb, pb| out[va + vb] += pa * pb } }
  end

  def merge_weighted!(target, pmf, weight)
    pmf.each { |value, chance| target[value] = target.fetch(value, 0.0) + chance * weight }
  end

  def negate(pmf) = pmf.transform_keys(&:-@)

  # A Boon (+N) rerolls dice showing 1..N; a Bane (-N) rerolls (21-N)..20.
  def reroll_band(net_modifier)
    n = net_modifier.to_i
    return nil if n.zero?
    size = [ n.abs, MAX_BAND_SIZE ].min
    n.positive? ? (DIE_MIN..DIE_MIN + size - 1) : (DIE_MAX - size + 1..DIE_MAX)
  end

  def apply_reroll(value, band, die)
    value = die.call while band&.cover?(value)
    value
  end
end
