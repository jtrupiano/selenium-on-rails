
def load_db
  default_file = File.join(RAILS_ROOT, 'config', 'database.yml')
  environmentalist_file = File.join(RAILS_ROOT, 'config', RAILS_ENV, 'database.yml')

  path = File.exists?(environmentalist_file) ? environmentalist_file : default_file
  YAML.load_file(path)[RAILS_ENV]
end

# used to conditionally pass along a password to the 
def pluck_pass_str(db_config)
  pass_str = db_config['password']
  if !pass_str.nil?
    pass_str = "-p#{pass_str.gsub('$', '\$')}"
  end
  pass_str || ''
end

namespace :sel do 
  desc "Drops, creates, loads schema, loads stories, then runs mysqldump and stores it in tmp/story-dump.sql.  Run anytime your StoryHelper data changes."
  task :rebuild => [:environment, "db:drop", "db:create", "db:schema:load", "db:stories"] do
    db = load_db
    output = `mysqldump -u #{db["username"]} #{pluck_pass_str(db)} #{db["database"]} > tmp/story-dump.sql`
    raise("Error encountered running mysqldump: #{output}") if $? != 0
  end
  
  desc "Drops, creates and then loads in the data dump from sel:rebuild (sitting in tmp/story-dump)"
  task :restore => [:environment, "db:drop", "db:create"] do
    db = load_db
    output = `mysql -u #{db["username"]} #{pluck_pass_str(db)} #{db["database"]} < tmp/story-dump.sql`
    raise("Error encountered running mysql import: #{output}") if $? != 0
  end
end