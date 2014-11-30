desc 'Cleanup'
task :cleanup => :environment do
  @redis ||= Redis.new(:url => ENV['REDISTOGO_URL'])
  @redis.del("tags-#{Rails.env}")
  
  Idea.all.each do |idea|
    puts "CLEANING UP #{idea.sha}"
    client = Swiftype::Client.new
    begin
      client.destroy_document('engine', 'ideas', idea.sha)
    rescue Swiftype::NonExistentRecord
      puts "No Swiftype record for #{idea.sha}"
    end
    idea.destroy
  end
end
