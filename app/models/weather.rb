# The weather in the game world. Staff can write today's weather in Game
# settings; when they haven't and the game makes its own weather, it comes
# from the in-game season. It changes every few real hours, often staying
# the same for a while, and everyone sees the same weather at the same time
# without anything being saved: each stretch of hours picks from its own
# fixed random numbers.
module Weather
  CHANGES_EVERY = 6.hours
  # The chance the weather carries on from the last stretch of hours.
  STAYS = 0.5

  SEASONS = {
    "spring" => [ "Clear and mild", "Soft showers drifting through", "Bright, with a fresh breeze", "Overcast and cool", "Heavy spring rain", "Sunshine between quick showers" ],
    "summer" => [ "Hot and sunny", "Warm and clear", "Humid, with thunder in the air", "A summer thunderstorm", "Warm, under high thin cloud", "A long, golden evening" ],
    "autumn" => [ "Crisp and clear", "Grey drizzle", "Windy, with leaves on the move", "Fog until midday", "Cold rain", "Mild and misty" ],
    "winter" => [ "Frost and a pale sun", "Snow falling", "A bitter wind", "Freezing fog", "Sleet", "Grey and cold" ]
  }.freeze

  module_function

  # Today's weather as words, or nil when there is none.
  def now(settings = GameSetting.current, at: Time.current)
    settings.weather.presence || (made_up(settings, at) if settings.weather_auto?)
  end

  def season(settings = GameSetting.current)
    month = IcClock.today(settings).month
    month = ((month + 5) % 12) + 1 if settings.weather_southern?
    case month
    when 3..5 then "spring"
    when 6..8 then "summer"
    when 9..11 then "autumn"
    else "winter"
    end
  end

  def made_up(settings, at)
    choices = SEASONS.fetch(season(settings))
    slot = at.to_i / CHANGES_EVERY.to_i
    # Walk back while the weather "stays", up to a day, then pick.
    4.times do
      break unless Random.new(slot).rand < STAYS
      slot -= 1
    end
    choices[Random.new(slot * 7 + 3).rand(choices.size)]
  end
end
