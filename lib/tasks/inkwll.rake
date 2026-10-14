namespace :inkwll do
  desc "Make an account a Founder (top-level staff who can create more): bin/rails \"inkwll:make_founder[PlayerName]\""
  task :make_founder, [ :name ] => :environment do |_task, args|
    account = Account.find_by!(username: args[:name].to_s.strip.downcase)
    account.update!(staff_level: :wellkeeper, founder: true)
    puts "#{account.display_name} is now a Wellkeeper and a Founder."
  end
end
