# Leftover "Probe" players from the old live-game browser check. See
# lib/inkwll/probes.rb and docs/deploying.md.
#
#   bin/rails inkwll:probes:list       shows them and what they made
#   bin/rails inkwll:probes:clean_up   removes them completely: forum posts,
#                                      OOC messages, Passages, characters, account
namespace :inkwll do
  namespace :probes do
    desc "List leftover Probe players and what they made"
    task list: :environment do
      Inkwll::Probes.report($stdout)
    end

    desc "Remove leftover Probe players and everything they made"
    task clean_up: :environment do
      Inkwll::Probes.clean_up($stdout)
    end
  end
end
