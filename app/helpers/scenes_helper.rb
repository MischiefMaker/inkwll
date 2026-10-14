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
  def player_icon(account)
    hue = Zlib.crc32(account.username) % 360
    tag.span account.display_name.first.upcase, class: "player-icon", aria: { hidden: true },
      style: "background: hsl(#{hue} 45% 45%)"
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
