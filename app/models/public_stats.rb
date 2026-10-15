# The counts shown at the bottom of the front page: players, characters,
# Chapters and Archives. Counts only, and only what anyone may know exists:
# archived players, retired and roster characters, and private or hidden
# Chapters (unless every player agreed to make them public) are left out.
module PublicStats
  def self.counts
    players = Account.where(system: false, archived_at: nil)
    characters = Character.active.approved.where(account_id: players.select(:id))
    chapters = Scene.where(visibility: "joinable").or(Scene.where.not(made_public_at: nil))
    { players: players.count, characters: characters.count,
      chapters: chapters.count, archives: chapters.finished.count }
  end
end
