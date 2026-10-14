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

    if current_account.can?(:review_apps)
      groups["Waiting on staff"] << admin_link("Applications", admin_applications_path, %w[ applications ], Character.submitted.count)
      roster_waiting = RosterApplication.pending.count + Character.active.where.not(roster_requested_at: nil).count
      groups["Waiting on staff"] << admin_link("Roster", admin_roster_path, %w[ roster roster_applications roster_characters ], roster_waiting)
      if Soul.enabled?
        soul_waiting = Soul::BnbRequest.pending.count + Soul::Culmination.proposed.count + Soul::AwardSuggestion.pending.count
        groups["Waiting on staff"] << admin_link("SOUL requests", admin_soul_reviews_path, %w[ soul_reviews ], soul_waiting)
      end
      if Inkling.enabled?
        groups["Waiting on staff"] << admin_link("Inklings", admin_inklings_path, %w[ inklings ], Inkling.submitted.open.count)
      end
      if Grimoire.enabled?
        groups["Game systems"] << admin_link("Grimoire", admin_grimoire_path, %w[ grimoire grimoire_branches grimoire_spells grimoire_proposals ], Grimoire::Proposal.pending.count)
      end
      if Soul.enabled?
        groups["Game systems"] << admin_link("Boons and Banes", admin_soul_bnbs_path, %w[ soul_bnbs ])
      end
    end

    if current_account.can?(:handle_reports)
      groups["Moderation"] << admin_link("Reports", admin_reports_path, %w[ reports warnings ], Report.unresolved.count)
    end
    if current_account.can?(:ban)
      groups["Moderation"] << admin_link("Bans", admin_bans_path, %w[ bans ])
    end

    if current_account.can?(:build)
      groups["Game world"] << admin_link("Building", admin_areas_path, %w[ areas rooms exits bulk_builds ])
    end

    if current_account.can?(:manage_staff)
      groups["Players and characters"] << admin_link("Players and staff", admin_accounts_path, %w[ accounts ])
    end
    if current_account.can?(:delete_characters)
      groups["Players and characters"] << admin_link("Characters", admin_characters_path, %w[ characters ])
    end

    if current_account.can?(:change_game_settings)
      groups["Game world"] << admin_link("#{term(:scene)} labels", admin_scene_labels_path, %w[ scene_labels ])
      groups["Players and characters"] << admin_link("Character groups", admin_character_groups_path, %w[ character_groups ])
      groups["Players and characters"] << admin_link("Profile fields", admin_profile_fields_path, %w[ profile_fields ])
      groups["Game systems"] << admin_link("SOUL", admin_soul_path, %w[ soul soul_aspects soul_skills ])
      groups["Settings"] << admin_link("Game settings", edit_admin_game_settings_path, %w[ game_settings ])
      groups["Settings"] << admin_link("Features", edit_admin_features_path, %w[ features ])
      groups["Settings"] << admin_link("Look", edit_admin_skin_path, %w[ skins ])
    end

    groups.reject { |_, links| links.empty? }.to_a
  end

  private

  def admin_link(label, path, controllers, waiting = 0)
    AdminLink.new(label: label, path: path, current: controller_name.in?(controllers), waiting: waiting)
  end
end
