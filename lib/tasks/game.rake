namespace :game do
  desc "Set up all achievements in the database"
  task seed_achievements: :environment do
    puts "Creating achievements..."
    Achievement.seed_achievements
    puts "Created #{Achievement.count} achievements successfully!"
  end
end
