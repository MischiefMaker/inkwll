# The game's in-character date. Staff set "today's date in the game" and how
# many game days pass per real day; from then on the date moves by itself.
# Until it's set, the game date is the real date.
module IcClock
  module_function

  def today(settings = GameSetting.current)
    return Date.current unless settings.ic_anchor_date && settings.ic_anchor_at

    days = ((Time.current - settings.ic_anchor_at) / 1.day * settings.ic_days_per_day.to_f).floor
    settings.ic_anchor_date + days
  end

  # Whole years from birthday to the game's today, or nil.
  def age(birthday)
    return unless birthday
    now = today
    years = now.year - birthday.year
    years -= 1 if now.month < birthday.month || (now.month == birthday.month && now.day < birthday.day)
    years.negative? ? nil : years
  end
end
