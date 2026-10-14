# Reads SOUL's numbers from config/soul.yml and does the arithmetic that
# doesn't need the database.
module Soul::Rules
  module_function

  def config
    @config ||= Rails.application.config_for(:soul).as_json
  end

  def skill_max = config.dig("ratings", "skill_max")
  def aspect_max = config.dig("ratings", "aspect_max")

  # --- Resonance -------------------------------------------------------------

  def resonance_enabled? = config.dig("resonance", "enabled")
  def resonance_range = resonance_enabled? ? (config.dig("resonance", "min")..config.dig("resonance", "max")) : (0..0)

  # Starting points and the highest starting Skill, by Resonance.
  def chargen_allowance(resonance)
    r = resonance_enabled? ? resonance.to_i : 0
    settings = config["resonance"]
    {
      skill_points: settings["skill_points"] + r * settings["skill_points_per_level"],
      starting_cap: [ settings["starting_cap"] + r * settings["starting_cap_per_level"], skill_max ].min,
      aspect_points: settings["aspect_points"] + r * settings["aspect_points_per_level"]
    }
  end

  # --- Rolls -------------------------------------------------------------------

  def difficulties = config.dig("rolls", "difficulties")

  def aspect_bonus(aspect_rating)
    (aspect_rating.to_i * config["aspect_weight"].to_f).round
  end

  DEGREES = %w[ exceptional_success success complicated_success lucky_failure failure catastrophic_failure ].freeze
  SUCCESSES = %w[ exceptional_success success complicated_success ].freeze

  DEGREE_TEXT = {
    "exceptional_success" => "Exceptional success. They succeed, and may add a benefit from their success.",
    "success" => "Success.",
    "complicated_success" => "Complicated success. They succeed, but should add a complication.",
    "lucky_failure" => "Lucky failure. They fail, but may add a benefit despite failing.",
    "failure" => "Failure.",
    "catastrophic_failure" => "Catastrophic failure. They fail, and should add a complication."
  }.freeze

  def degree_for(margin)
    thresholds = config.dig("rolls", "degrees")
    DEGREES.find { |degree| thresholds.key?(degree) && margin >= thresholds[degree] } || "catastrophic_failure"
  end

  def extraordinary?(probability)
    probability <= config.dig("rolls", "extraordinary_below").to_f
  end

  # --- XP ----------------------------------------------------------------------

  def weekly_award = config.dig("xp", "weekly_award").to_i
  def scene_award = config.dig("xp", "scene_award").to_i
  def catchup = config.dig("xp", "catchup")

  # The cost to raise a Skill or Aspect to new_rating (SOUL's formula):
  #   base = ceil(new_rating² × numerator ÷ denominator)
  #   development = base_dev + (XP spent so far ÷ scale) ^ exponent
  #   resonance = 1 + rate × Resonance (+ surcharge × Resonance when positive)
  #   cost = ceil(ceil(base × development × resonance) × multiplier)
  # Aspects cost four times as much by default.
  def cost(new_rating:, xp_spent:, resonance:, aspect: false)
    c = config.dig("xp", "cost")
    base = (new_rating.to_i**2 * c["skill_curve_numerator"]).fdiv(c["skill_curve_denominator"]).ceil
    development = c["development_base"] + (xp_spent.to_f / c["development_scale"])**c["development_exponent"]
    r = resonance_enabled? ? resonance.to_i : 0
    resonance_modifier = r.positive? ? 1 + c["positive_resonance_rate"] * r + c["positive_resonance_surcharge"] * r : 1 + c["negative_resonance_rate"] * r
    equivalent = (base * development * resonance_modifier).ceil
    (equivalent * c[aspect ? "aspect_cost_multiplier" : "skill_cost_multiplier"]).ceil
  end
end
