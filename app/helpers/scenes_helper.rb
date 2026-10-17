module ScenesHelper
  # A character's small icon, or their initial in a circle if they have none.
  def character_icon(character, size: :small)
    classes = "character-icon character-icon--#{size}"
    if character&.icon&.attached?
      image_tag icon_picture(character.icon), alt: "", class: classes
    elsif character&.gm? && character.account.icon.attached?
      image_tag icon_picture(character.account.icon), alt: "", class: "#{classes} character-icon--gm"
    else
      tag.span (character&.name || "?").first.upcase, class: "#{classes} character-icon--initial", aria: { hidden: true }
    end
  end

  # A player's tiny icon in the OOC Chat. It's never a character's icon,
  # which could show who plays that character. Guests get a grey pen nib.
  # Players who uploaded a player icon get that.
  def player_icon(ooc_message)
    if ooc_message.guest?
      nib_icon(css: "player-icon player-icon--tiny player-icon--guest player-icon--default")
    else
      player_avatar(ooc_message.account, size: :tiny)
    end
  end

  # A player's picture: their uploaded icon, or the default pen nib (owner).
  def player_avatar(account, size: :tiny)
    classes = "player-icon player-icon--#{size}"
    # A picture that was just refused isn't saved, so it can't be shown.
    if account.icon.attached? && account.icon.blob.persisted?
      image_tag icon_picture(account.icon), alt: "", class: "#{classes} player-icon--image"
    else
      nib_icon(css: "#{classes} player-icon--default")
    end
  end

  # Who a post is shown as: the character, the NPC (with who played it), or
  # the narrator.
  def pose_byline(pose)
    case pose.kind
    when "npc" then "#{pose.npc_name} (NPC, played by #{pose.character&.name})"
    when "narration" then "Narration by #{pose.character&.name}"
    when "ooc" then "#{pose.character&.name} (OOC)"
    when "roll" then "Roll"
    when "letter" then "#{pose.letter_style == "text" ? "A text" : "A letter"} from #{pose.character&.name}#{" to #{pose.letter_to}" if pose.letter_to}"
    when "aside" then "Aside from #{pose.character&.name}"
    when "mutter" then "#{pose.character&.name} mutters to #{pose.to_characters.map(&:name).to_sentence}"
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

  # The lock or eye shown beside a private or hidden Chapter's badge.
  def scene_visibility_mark(scene)
    return if scene.visibility_joinable?
    visibility_mark(scene.visibility_hidden? ? :you_only : :you_and_staff, label: scene_visibility_label(scene))
  end

  def pose_mode_label(mode)
    t("terms.pose_modes.#{mode}")
  end

  # "Take turns", or "3-Passage rule (taking turns until there are four)".
  # The labels on a Chapter, such as content warnings. Staff define them.
  def scene_labels(scene)
    return "" if scene.label_ids.blank?
    @all_scene_labels ||= SceneLabel.ordered.index_by(&:id)
    labels = scene.label_ids.filter_map { |id| @all_scene_labels[id] }
    return "" if labels.empty?
    tag.span(class: "scene-labels") do
      safe_join(labels.map { |label| tag.span(label.name, class: "scene-label scene-label--#{label.id}", title: label.description) }, " ")
    end
  end

  def scene_mode_summary(scene)
    label = pose_mode_label(scene.pose_mode)
    if scene.three_pose? && scene.turn_based?
      "#{label} (taking turns until there are #{Scene::Turns::THREE_POSE_MINIMUM})"
    else
      label
    end
  end

  # The Chapter layout: the Chapter's speed if it has one (live chat
  # looks like Chat, forum speed like Forum), otherwise the game's layout from
  # Admin → Look: "manuscript", "forum" or "chat".
  def chapter_layout
    @chapter_layout ||= @scene&.layout_for_speed || GameSetting.current.chapter_layout
  end

  SPEED_LABELS = { "" => "The game's usual look", "live" => "Live chat", "forum" => "Forum speed" }.freeze

  def scene_speed_fieldset(form)
    render "scenes/speed_field", form: form
  end

  # Classes on a Chapter page that pick its layout, for the stylesheet.
  def chapter_layout_classes
    setting = GameSetting.current
    classes = [ "scene--layout-#{chapter_layout}" ]
    classes << "scene--speed-#{@scene.speed}" if @scene&.speed
    if chapter_layout == "manuscript"
      classes << "scene--cast-#{setting.chapter_cast_portraits}" << "scene--portraits-#{setting.chapter_passage_portraits}"
    end
    classes.join(" ")
  end

  # Manuscript with large cast portraits shows a card per character under the title.
  def chapter_cast_cards?
    chapter_layout == "manuscript" && GameSetting.current.chapter_cast_portraits == "large"
  end

  # Forum, and Manuscript with large portraits, put a picture, the name and
  # details in a column beside each Passage.
  def passage_author_panel?
    return @passage_author_panel if defined?(@passage_author_panel)
    @passage_author_panel = chapter_layout == "forum" ||
      (chapter_layout == "manuscript" && GameSetting.current.chapter_passage_portraits == "large")
  end

  # Ids of the posts that come after a long pause, which Manuscript marks
  # with a scene break (✦ ✦ ✦), the way a book marks a jump in time.
  SCENE_BREAK_GAP = 12.hours
  def scene_break_ids(poses)
    return [] unless chapter_layout == "manuscript"
    poses.to_a.each_cons(2).filter_map { |before, after| after.id if after.created_at - before.created_at >= SCENE_BREAK_GAP }
  end
end
