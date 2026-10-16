# Whether a newer version than the one this game runs has been marked ready,
# for the Founder's "Needs Attention" box. Asks GitHub at most every ten
# minutes, and says nothing (no update) if GitHub can't be reached. Only
# the home Well can update itself, so other Wells never offer it.
module AvailableUpdate
  CACHE_KEY = "available_update/newest_ready"

  # The newest ready version's name when it differs from the running one, else nil.
  def self.for(account)
    return unless account&.founder?
    return if ENV["INKWLL_HOME_URL"].present?
    github = GithubActions.current
    return unless github.configured?
    newest = Rails.cache.fetch(CACHE_KEY, expires_in: 10.minutes) { github.releases.first&.tag.to_s }
    newest.presence unless newest.blank? || newest == ENV["INKWLL_VERSION"].presence
  rescue GithubActions::Error
    nil
  end
end
