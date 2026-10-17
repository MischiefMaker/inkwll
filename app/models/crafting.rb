# Items and Crafting (docs/crafting.md). Items, Belongings, the staff
# catalogue, shops in Places, Give and Trade work whenever the Economy is
# on. Making items, their features and the Market need Crafting switched on
# too.
#
# Item features reach SOUL rolls through SOUL's roll-extras hook
# (Soul.offer_roll_extras), so SOUL never needs to know what an item is.
module Crafting
  LEVELS = %w[ minor major legendary ].freeze
  # The roll starts here and each feature makes it a step harder.
  BASE_DIFFICULTY = "standard"

  class Error < StandardError; end

  def self.table_name_prefix = "crafting_"

  # Items, shops, Give and Trade.
  def self.items_enabled? = Economy.enabled?

  # Making items, features in rolls and the Market.
  def self.enabled?
    Economy.enabled? && GameSetting.current.crafting_enabled?
  end

  def self.levels
    LEVELS.first(LEVELS.index(GameSetting.current.crafting_highest_level).to_i + 1)
  end

  def self.feature_cost(level)
    level.in?(LEVELS) ? GameSetting.current.public_send(:"crafting_#{level}_cost") : 0
  end

  # nil means no limit.
  def self.max_features
    GameSetting.current.crafting_max_features.then { |limit| limit.positive? ? limit : nil }
  end

  def self.difficulty_for(feature_count)
    names = Soul::Rules.difficulties.keys
    start = names.index(BASE_DIFFICULTY) || 0
    names[[ start + feature_count, names.size - 1 ].min]
  end

  # Item features and flaws that can count in this character's rolls.
  def self.roll_extras_for(character)
    return [] unless enabled?
    items = character.items.where("cardinality(feature_ids) > 0 OR flaw_name IS NOT NULL").order(:name).to_a
    features = Crafting::Feature.approved.where(id: items.flat_map(&:feature_ids)).index_by(&:id)
    items.flat_map do |item|
      extras = item.feature_ids.filter_map { |id| features[id] }.map do |feature|
        Soul::RollExtra.new(key: "item-#{item.id}-#{feature.id}", name: "#{feature.name} (#{item.name})", kind: "boon", level: feature.level, skill_ids: feature.skill_ids, always: false)
      end
      extras << Soul::RollExtra.new(key: "item-#{item.id}-flaw", name: "#{item.flaw_name} (#{item.name})", kind: "bane", level: "minor", skill_ids: item.flaw_skill_ids, always: true) if item.flaw_name
      extras
    end
  end

  # Tells a character's player about an item.
  def self.alert!(character, note)
    Alert.notify!(character.account, "item", character: character, note: note) if character&.account && !character.retired?
  end

  # An approved character being played, by name, who can receive items.
  def self.find_character(name)
    name = name.to_s.squish.downcase
    Character.active.where(status: "approved").where("lower(name) = ?", name).first if name.present?
  end

  def self.log!(item, kind, character:, other: nil, note: nil, actor: nil, quantity: item.quantity)
    Crafting::ItemEvent.create!(item: item, item_name: item.name, quantity: quantity, character: character, other_character: other, kind: kind, note: note.to_s.squish.first(200).presence, actor: actor)
  end

  # Makes an item: pays the cost, rolls the item type's Skill (when SOUL is
  # on and it has one) and acts on the result. Returns [item or nil, text].
  def self.craft!(character, item_type:, name:, description:, features:, pictures: [], bnbs: nil, extras: nil, scene: nil, actor: nil)
    raise Error, "Crafting is switched off." unless enabled?
    raise Error, "#{character.name} can't craft until they're approved." unless character.approved? && !character.retired?
    raise Error, "#{item_type.name} can't have more than #{max_features} features." if max_features && features.size > max_features
    features.each do |feature|
      raise Error, "#{feature.name} isn't available." unless feature.approved? && feature.level.in?(levels)
      raise Error, "#{feature.name} doesn't fit #{item_type.name}." unless feature.fits?(item_type)
    end
    feature_cost = features.sum(&:cost)
    cost = item_type.base_cost + feature_cost
    item = character.items.new(name: name, description: description, item_type: item_type, feature_ids: features.map(&:id),
      maker: character, maker_name: character.name, made_at: Time.current)
    pictures.each { |picture| item.pictures.attach(picture) }
    raise Error, item.errors.full_messages.to_sentence unless item.valid?

    Economy::Account.transaction do
      purse = Economy.account_for(character)
      purse.debit!(cost, kind: "craft", note: "Crafting #{name}", actor: actor) if cost.positive?

      skill = item_type.skill if Soul.enabled?
      roll = skill && character.roll_skill(skill, difficulty_for(features.size), bnbs: bnbs, extras: extras)
      degree = roll&.degree || "success"
      refund = case degree
      when "exceptional_success" then feature_cost / 2
      when "lucky_failure", "failure" then cost / 2
      else 0
      end
      purse.credit!(refund, kind: "craft", note: degree == "exceptional_success" ? "Masterwork: half the features' cost back" : "Half the cost back from a failed attempt", actor: actor) if refund.positive?

      made = Soul::Rules::SUCCESSES.include?(degree)
      if made
        item.masterwork = degree == "exceptional_success"
        if degree == "complicated_success"
          item.flaw_name = "Flawed"
          item.flaw_skill_ids = features.flat_map(&:skill_ids).uniq
        end
        item.save!
        log!(item, "made", character: character, actor: actor, note: ("Masterwork" if item.masterwork?))
      end

      outcome = case degree
      when "exceptional_success" then " (Masterwork)."
      when "complicated_success" then ", but it has a flaw."
      when "success" then "."
      when "catastrophic_failure" then ", but it's ruined and everything spent is lost."
      else ", but fails and loses half of what was spent."
      end
      text = "#{character.name} crafts #{name}#{outcome}"
      text = "#{text} (#{skill.name} against #{roll.difficulty_name.humanize}, #{roll.difficulty}#{" with #{roll.applied_text}" if roll.applied.any?}: #{roll.result}.)" if roll
      if scene&.writable? && scene.participant_for(character)
        pose = scene.add_game_line!(character, text)
        roll&.assign_attributes(scene: scene, pose: pose)
      end
      roll&.save!
      [ (item if made), text ]
    end
  end
end
