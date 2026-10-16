# Throwaway "Probe" players left on a game by the old browser check, which
# signed up on the live game with a shared password (see docs/deploying.md).
# They are named Probe plus a 13-digit timestamp and have an @example.com
# email, so real players are never matched. Used by lib/tasks/probes.rake.
module Inkwll
  module Probes
    def self.accounts
      Account.where("username ~ '^probe[0-9]{13}$'").where("email LIKE '%@example.com'")
    end

    # Prints each Probe player and what they made, and returns them.
    def self.report(out)
      found = accounts.order(:created_at).to_a
      out.puts "#{found.size} Probe #{found.size == 1 ? "player" : "players"} found."
      found.each do |account|
        out.puts "- #{account.display_name} (made #{account.created_at.utc.to_fs(:db)} UTC#{", archived" if account.archived?}): " \
          "#{account.characters.count} characters, #{ForumTopic.where(account: account).count} forum threads, " \
          "#{ForumPost.where(account: account).count} forum posts, #{account.ooc_messages.count} OOC messages, " \
          "#{Pose.where(character: account.characters).count} Passages"
      end
      found
    end

    # Archives each Probe player (they can't log in, their characters are
    # retired) and deletes their forum threads, forum posts and OOC messages.
    def self.clean_up(out)
      found = report(out)
      found.each do |account|
        Account.transaction do
          ForumTopic.where(account: account).destroy_all
          ForumPost.where(account: account).destroy_all
          account.ooc_messages.destroy_all
          account.archive! unless account.archived?
          # Archived players can't log in, but the old password was public,
          # so replace it anyway.
          account.update_columns(password_digest: BCrypt::Password.create(SecureRandom.base58(32)))
        end
        out.puts "Cleaned up #{account.display_name}."
      end
      found
    end
  end
end
