
def load_db
  default_file = File.join(RAILS_ROOT, 'config', 'database.yml')
  environmentalist_file = File.join(RAILS_ROOT, 'config', RAILS_ENV, 'database.yml')

  path = File.exists?(environmentalist_file) ? environmentalist_file : default_file
  YAML.load_file(path)[RAILS_ENV]
end

namespace :sel do 
  desc "Drops, creates, loads schema, loads stories, then runs mysqldump and stores it in tmp/story-dump.sql.  Run anytime your StoryHelper data changes."
  task :rebuild => ["db:drop", "db:create", "db:schema:load", "db:stories:load"] do
    db = load_db
    `mysqldump -u #{db["username"]} #{db["database"]} > tmp/story-dump.sql`
  end
  
  desc "Drops, creates and then loads in the data dump from sel:rebuild (sitting in tmp/story-dump)"
  task :restore => ["db:drop", "db:create"] do
    db = load_db
    `mysql -u #{db["username"]} #{db["database"]} < tmp/story-dump.sql`
  end
end