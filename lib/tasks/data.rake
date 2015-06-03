desc 'Migrate authors'
task :migrate_authors => :environment do
  Idea.all.each do |idea|
    if user = User.find(idea.user_id)
      puts "MIGRATING #{idea.sha}"
      Authorship.create!(:user_id => user.id, :idea_id => idea.id)
    else
      puts "Can't find user for idea #{idea.id}"
    end
  end
end
