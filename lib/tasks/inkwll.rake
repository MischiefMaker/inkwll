namespace :inkwll do
  desc "Give an account staff (admin) powers: bin/rails \"inkwll:make_admin[username]\""
  task :make_admin, [ :username ] => :environment do |_task, args|
    account = Account.find_by!(username: args[:username].to_s.strip.downcase)
    account.update!(admin: true)
    puts "#{account.username} is now an admin."
  end
end
