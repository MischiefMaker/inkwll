# The admin panel's side menu: links grouped under headings, like a
# Jcink admin CP. Each staff member only sees the links their job allows,
# and a heading with nothing under it is left out.
module AdminMenuHelper
  AdminLink = Struct.new(:label, :path, :current, :waiting, keyword_init: true)

  # The link to the admin front page, which sits above the headings.
  def admin_menu_overview
    admin_link("Overview", admin_root_path, %w[ dashboard ])
  end

  # A list of [heading, links] pairs, in the order they appear.
  def admin_menu_groups
    groups = {
      "Waiting on staff" => [],
      "Game world" => [],
      "Players and characters" => [],
      "Moderation" => [],
      "Game systems" => [],
      "Settings" => []
    }

    waiting = StaffWaiting.for(current_account).to_h { |item| [ item.key, item.count ] }
    if current_account.can?(:review_apps)
      groups["Waiting on staff"] << admin_link("Applications", admin_applications_path, %w[ applications ], waiting[:applications])
      groups["Players and characters"] << admin_link("NPCs", admin_npcs_path, %w[ npcs ])
      groups["Waiting on staff"] << admin_link("Roster", admin_roster_path, %w[ roster roster_applications roster_characters ], waiting[:roster])
      if Soul.enabled?
        groups["Waiting on staff"] << admin_link("SOUL requests", admin_soul_reviews_path, %w[ soul_reviews ], waiting[:soul])
      end
      if Inkling.enabled?
        groups["Waiting on staff"] << admin_link("Inklings", admin_inklings_path, %w[ inklings ], waiting[:inklings])
      end
      if Faction.enabled?
        groups["Waiting on staff"] << admin_link("#{term(:faction)} requests", factions_path, %w[], waiting[:factions])
      end
      if Grimoire.enabled?
        groups["Game systems"] << admin_link("Grimoire", admin_grimoire_path, %w[ grimoire grimoire_branches grimoire_spells grimoire_proposals ], waiting[:grimoire])
      end
      if Soul.enabled?
        groups["Game systems"] << admin_link("Boons and Banes", admin_soul_bnbs_path, %w[ soul_bnbs ])
      end
      if Economy.enabled?
        groups["Game systems"] << admin_link("Economy", admin_economy_path, %w[ economy economy_adjustments economy_schedules economy_allowance_changes ])
        groups["Game systems"] << admin_link(term(:domain, count: 2), admin_domains_path, %w[ domains ]) if Domain.enabled? && current_account.can?(:change_game_settings)
        groups["Game systems"] << admin_link("Item catalogue", admin_catalogue_items_path, %w[ catalogue_items items ])
        groups["Game systems"] << admin_link("Crafting", admin_crafting_path, %w[ crafting crafting_item_types crafting_features ], (Crafting::Feature.proposed.count if Crafting.enabled?)) if Crafting.enabled?
      end
    end

    if current_account.can?(:handle_reports)
      groups["Moderation"] << admin_link("Reports", admin_reports_path, %w[ reports warnings ], waiting[:reports])
      groups["Waiting on staff"] << admin_link("Rulings", admin_rulings_path, %w[ rulings ], waiting[:rulings] || 0)
    end
    if current_account.can?(:ban)
      groups["Moderation"] << admin_link("Bans", admin_bans_path, %w[ bans ])
    end

    if current_account.can?(:build)
      groups["Game world"] << admin_link("Building", admin_areas_path, %w[ areas rooms exits bulk_builds ])
      groups["Game world"] << admin_link("#{term(:scene)} ideas", admin_scene_ideas_path, %w[ scene_ideas ])
    end

    if current_account.can?(:manage_forums)
      groups["Game world"] << admin_link(term(:forum_board, count: 2), admin_forum_boards_path, %w[ forum_boards ])
    end

    if current_account.can?(:manage_staff)
      groups["Players and characters"] << admin_link("Players and staff", admin_accounts_path, %w[ accounts ], waiting[:players] || 0)
    end
    if current_account.can?(:review_apps)
      groups["Players and characters"] << admin_link("Name changes", admin_name_changes_path, %w[ name_changes ])
    end
    if current_account.can?(:delete_characters)
      groups["Players and characters"] << admin_link("Characters", admin_characters_path, %w[ characters ])
    end

    if current_account.can?(:change_game_settings)
      groups["Game world"] << admin_link("#{term(:scene)} labels", admin_scene_labels_path, %w[ scene_labels ])
      groups["Players and characters"] << admin_link("Character groups", admin_character_groups_path, %w[ character_groups ])
      groups["Players and characters"] << admin_link(term(:faction, count: 2), admin_factions_path, %w[ factions ])
      groups["Players and characters"] << admin_link("Profile fields", admin_profile_fields_path, %w[ profile_fields ])
      groups["Game systems"] << admin_link("SOUL", admin_soul_path, %w[ soul soul_aspects soul_skills ])
      groups["Settings"] << admin_link("Game settings", edit_admin_game_settings_path, %w[ game_settings ])
      groups["Settings"] << admin_link("Features", edit_admin_features_path, %w[ features ])
      groups["Settings"] << admin_link("Look", edit_admin_skin_path, %w[ skins ])
    end

    if current_account.founder?
      groups["Settings"] << admin_link("Wells", admin_wells_path, %w[ wells well_updates ])
      groups["Settings"] << admin_link("Import a world", admin_world_import_path, %w[ world_imports ])
    end

    groups.reject { |_, links| links.empty? }.to_a
  end

  # The buttons across the top of the admin front page: [label, path, css kind]
  # for the quick jobs this staff member's level allows.
  def admin_quick_actions
    actions = []
    actions << [ "New Character", new_character_path, "character" ]
    if current_account.can?(:build)
      actions << [ "New #{term(:room)}", new_admin_room_path, "place" ]
      actions << [ "New #{term(:area)}", new_admin_area_path, "area" ]
    end
    actions << [ "New Wiki Page", new_wiki_page_path, "wiki" ] if WikiPage.enabled?
    actions << [ "Player List", admin_accounts_path, "players" ] if current_account.can?(:manage_staff)
    actions << [ "Character List", admin_characters_path, "characters" ] if current_account.can?(:delete_characters)
    actions << [ "Applications", admin_applications_path, "applications" ] if current_account.can?(:review_apps)
    actions << [ "Reports", admin_reports_path, "reports" ] if current_account.can?(:handle_reports)
    actions << [ "Bans", admin_bans_path, "bans" ] if current_account.can?(:ban)
    actions << [ "Game Settings", edit_admin_game_settings_path, "settings" ] if current_account.can?(:change_game_settings)
    actions
  end

  # Where each kind of waiting work (see StaffWaiting) is handled.
  def staff_waiting_path(key)
    case key
    when :applications then admin_applications_path
    when :roster then admin_roster_path
    when :soul then admin_soul_reviews_path
    when :inklings then admin_inklings_path
    when :grimoire then admin_grimoire_path
    when :factions then factions_path
    when :reports then admin_reports_path
    when :rulings then admin_rulings_path
    when :players then admin_accounts_path
    end
  end

  private

  def admin_link(label, path, controllers, waiting = 0)
    AdminLink.new(label: label, path: path, current: controller_name.in?(controllers), waiting: waiting)
  end
end
