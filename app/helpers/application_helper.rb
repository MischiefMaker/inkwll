module ApplicationHelper
  # The word players see for one of Inkwll's things, from config/locales/en.yml.
  # term(:room) is "Setting"; term(:room, count: 2) is "Settings".
  def term(name, count: 1)
    t("terms.#{name}", count: count)
  end
end
