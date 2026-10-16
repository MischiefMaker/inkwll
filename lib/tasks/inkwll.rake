namespace :inkwll do
  desc "Make an account a Founder (top-level staff who can create more): bin/rails \"inkwll:make_founder[PlayerName]\""
  task :make_founder, [ :name ] => :environment do |_task, args|
    account = Account.find_by!(username: args[:name].to_s.strip.downcase)
    account.update!(staff_level: :wellkeeper, founder: true)
    puts "#{account.display_name} is now a Wellkeeper and a Founder."
  end

  desc "Import a world pack (see docs/world-packs.md) as a Founder: bin/rails \"inkwll:import_world[path/to/pack.json,FounderName]\" (add ,remove to take away what the pack leaves out)"
  task :import_world, [ :path, :name, :remove ] => :environment do |_task, args|
    account = Account.find_by!(username: args[:name].to_s.strip.downcase)
    abort "#{account.display_name} isn't a Founder." unless account.founder?
    pack = WorldPack.parse(File.read(args[:path]))
    remove = args[:remove] == "remove"
    pack.preview(remove_unlisted: remove).group_by(&:action).each { |action, changes| puts "#{action}: #{changes.size}" }
    pack.import!(by: account, remove_unlisted: remove)
    puts "Imported #{pack.name}."
  end
end
