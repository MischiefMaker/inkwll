module ScenesHelper
  # A character's small icon, or their initial in a circle if they have none.
  def character_icon(character, size: :small)
    classes = "character-icon character-icon--#{size}"
    if character&.icon&.attached?
      image_tag character.icon, alt: "", class: classes
    else
      tag.span (character&.name || "?").first.upcase, class: "#{classes} character-icon--initial", aria: { hidden: true }
    end
  end

  # A player's tiny icon in the OOC Chat: their initial on a colour picked
  # from their name, so each player keeps the same colour. It's never a
  # character's icon, which could show who plays that character.
  # Guests get a plain grey one. Players who uploaded a player icon get that.
  def player_icon(ooc_message)
    if ooc_message.guest?
      tag.span ooc_message.guest_name.first.upcase, class: "player-icon player-icon--guest", aria: { hidden: true }
    else
      player_avatar(ooc_message.account, size: :tiny)
    end
  end

  # A player's picture: their uploaded icon, or their initial on their colour.
  def player_avatar(account, size: :tiny)
    classes = "player-icon player-icon--#{size}"
    # A picture that was just refused isn't saved, so it can't be shown.
    if account.icon.attached? && account.icon.blob.persisted?
      image_tag account.icon, alt: "", class: "#{classes} player-icon--image"
    else
      hue = Zlib.crc32(account.username) % 360
      tag.span account.display_name.first.upcase, class: classes, aria: { hidden: true }, style: "background: hsl(#{hue} 45% 45%)"
    end
  end

  # Who a post is shown as: the character, the NPC (with who played it), or
  # the narrator.
  def pose_byline(pose)
    case pose.kind
    when "npc" then "#{pose.npc_name} (NPC, played by #{pose.character&.name})"
    when "narration" then "Narration by #{pose.character&.name}"
    when "ooc" then "#{pose.character&.name} (OOC)"
    else pose.character&.name.to_s
    end
  end

  # How long since a character last posted or moved, MUSH-style: "active",
  # "idle 25m", "idle 3h", "idle 2d". Nothing if they never have.
  def idle_label(time)
    return unless time
    idle = Time.current - time
    if idle < 10.minutes then "active"
    elsif idle < 1.hour then "idle #{(idle / 60).floor}m"
    elsif idle < 1.day then "idle #{(idle / 3600).floor}h"
    else "idle #{(idle / 86_400).floor}d"
    end
  end

  def scene_visibility_label(scene)
    t("terms.scene_visibility.#{scene.visibility}")
  end

  def pose_mode_label(mode)
    t("terms.pose_modes.#{mode}")
  end

  # "Take turns", or "3-Passage rule (taking turns until there are four)".
  def scene_mode_summary(scene)
    label = pose_mode_label(scene.pose_mode)
    if scene.three_pose? && scene.turn_based?
      "#{label} (taking turns until there are #{Scene::Turns::THREE_POSE_MINIMUM})"
    else
      label
    end
  end
end
