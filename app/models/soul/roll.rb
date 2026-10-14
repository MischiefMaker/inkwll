# A SOUL roll made in a Chapter. The Passage it posted shows the result; this
# keeps the details (the dice, the bonuses, the chance) for anyone curious.
class Soul::Roll < ApplicationRecord
  belongs_to :character
  belongs_to :scene, optional: true
  belongs_to :pose, optional: true
  belongs_to :skill, class_name: "Soul::Skill", foreign_key: :soul_skill_id, optional: true
  belongs_to :storyteller, class_name: "Character", optional: true

  def applied_text
    Array(applied).map { |entry| "#{entry["name"]} (#{entry["level"].to_s.capitalize} #{entry["kind"].to_s.capitalize}, #{entry["modifier"].to_i.positive? ? "+" : ""}#{entry["modifier"]})" }.to_sentence
  end

  def succeeded? = Soul::Rules::SUCCESSES.include?(degree)
  def degree_text = Soul::Rules::DEGREE_TEXT.fetch(degree, degree.humanize)
  def base = skill_rating + aspect_bonus

  def dice_text
    segments = Array(dice["segments"])
    text = segments.map { |pair| pair.join(" + ") }.join(dice["mode"] == "implosion" ? ", minus " : ", then ")
    case dice["mode"]
    when "explosion" then "#{text} (doubles explode)"
    when "implosion" then "#{text} (double 1s implode)"
    else text
    end
  end
end
