set :application, "leo"
set :repository,  "http://galileoalby.unfuddle.com/svn/galileoalby_sites/"


default_run_options[:pty] = true

# be sure to change these
set :user, 'galileo'
set :domain, 'galileoalby.com'

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "orion.ocssolutions.com"
role :web, "orion.ocssolutions.com"
role :db,  "orion.ocssolutions.com", :primary => true
set :deploy_to, "/home/galileo/capistrano_deploy"

set :deploy_via, :remote_cache

set :use_sudo, false

# database.yml task
desc "Link in the production database.yml"
task :link_production_db do
  run "ln -nfs #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
end

# Passenger
namespace :deploy do
  
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  # Not needed
  task :start do
  end
 
  # Not needed
  task :stop do
  end
      
end

after "deploy:update_code", :link_production_db
after "deploy:restart", "deploy:cleanup"
