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
