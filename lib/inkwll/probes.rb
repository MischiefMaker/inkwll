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

    # Removes each Probe player completely: their forum threads and posts, OOC
    # messages, Messages, Passages, Chapters only their characters were in,
    # characters, and the account itself. Nothing is archived or kept.
    def self.clean_up(out)
      found = report(out)
      found.each do |account|
        Account.transaction do
          account.update_columns(active_character_id: nil)
          ForumTopic.where(account: account).destroy_all
          ForumPost.where(account: account).destroy_all
          account.ooc_messages.destroy_all
          Conversation.where(id: account.conversation_members.select(:conversation_id)).destroy_all
          account.characters.each { |character| remove_character(character) }
          account.reload.destroy!
        end
        out.puts "Removed #{account.display_name}."
      end
      out.puts "Removed #{found.size} Probe #{found.size == 1 ? "player" : "players"}." if found.any?
      found
    end

    def self.remove_character(character)
      Pose.where(character: character).destroy_all
      alone = Scene.joins(:participants).group("scenes.id")
        .having("BOOL_AND(scene_participants.character_id = ?)", character.id).where(id: character.scene_participants.select(:scene_id))
      alone.to_a.each(&:destroy!)
      character.reload.destroy!
    end
    private_class_method :remove_character
  end
end
