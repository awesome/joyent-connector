=begin #(fold)
++
Copyright 2004-2007 Joyent Inc.

Redistribution and/or modification of this code is 
governed by the GPLv2.

Report issues and contribute at http://dev.joyent.com/

$Id$
--
=end #(end)

Capistrano::Configuration.instance(:must_exist).load do
  namespace :joyent do
    
    desc "Copy configuration files to shared"
    task :copy_configs_to_shared, :roles => :app do
      put(File.read('lib/joyent_config.rb'),              "#{shared_path}/joyent_config.rb", :mode => 0644)
      put(File.read('config/database.yml'),               "#{shared_path}/database.yml",     :mode => 0644)
      put(File.read('config/facebook.yml'),               "#{shared_path}/facebook.yml",     :mode => 0644)
      put(File.read('config/environments/production.rb'), "#{shared_path}/production.rb",    :mode => 0644)
      put(File.read('config/mongrel_cluster.yml'), "#{shared_path}/mongrel_cluster.yml",    :mode => 0644)
    end
    
    desc "Copy configuration files from shared to release_path"
    task :copy_configs, :roles => :app do
      run "rm -rf #{release_path}/lib/joyent_config.rb"
      run "cp #{shared_path}/joyent_config.rb #{release_path}/lib/joyent_config.rb"  

      # Copy in the database.yml file
      run "rm -rf #{release_path}/config/database.yml"
      run "cp #{shared_path}/database.yml #{release_path}/config/database.yml"    

      # Copy in a stubbed out production
      run "rm -rf #{release_path}/config/environments/production.rb"
      run "cp #{shared_path}/production.rb #{release_path}/config/environments/production.rb"
      
      # Copy in the mongrel_cluster.yml file
      run "rm -rf #{release_path}/config/mongrel_cluster.yml"
      run "cp #{shared_path}/mongrel_cluster.yml #{release_path}/config/mongrel_cluster.yml"
      
      # Copy in the facebook.yml file
      run "rm -rf #{release_path}/config/facebook.yml"
      run "cp #{shared_path}/facebook.yml #{release_path}/config/facebook.yml"
    end
    
    desc "Ensure current_path will be a symlink, not a directory"
    task :remove_current_dir, :roles => :app do
      run "if [[ -d #{current_path} ]]; then rm #{current_path}; fi"
    end
    
    desc "Start the Joyent work script"
    task :start_joyent_job, :roles => :app do
      rails_env = fetch(:rails_env, "production")
      # exporting variables this way will also work with sh
      run <<-CMD
        RAILS_ENV=#{rails_env}; export RAILS_ENV; 
        sudo nohup ruby #{current_path}/script/joyent_job start; 
        sleep 5;
        sudo nohup ruby #{current_path}/script/joyent_job start_worker 3; 
        sleep 5
      CMD
    end

    desc "Stop the Joyent work script"
    task :stop_joyent_job, :roles => :app do
      sudo "ruby #{current_path}/script/joyent_job stop"    
    end

    desc "concatenate assets"
    task :cat_assets, :roles => :web do 
      run "cd #{current_path}; rake joyent:cat_assets"
    end
    
    desc "build gmime"
    task :gmime, :roles => :web do 
      run "cd #{current_path}; rake joyent:gmime"
    end
    
    desc "calendar subscription manifest"
    task :calendar_smf, :roles => :app do
      puts "set variables"
      service_name = application
      working_directory = current_path
      daemon = 'calendar_subscriptions'
      
      template = File.read("config/accelerator/joyent_daemon_smf_template.erb")
      buffer = ERB.new(template).result(binding)
      
      put buffer, "#{shared_path}/joyent_#{daemon}-smf.xml"
      
    end
    
    desc "import calendar subscription SMF"
    task :import_calendar_smf, :roles => :app do
      sudo "svccfg import #{shared_path}/joyent_calendar_subscriptions-smf.xml"
    end
    
    desc "start calendar subscription daemon"
    task :start_calendar_smf, :roles => :app do
      sudo "svcadm enable -r /site/ruby/joyent_calendar_subscriptions"
    end
    
    desc "stop calendar subscription daemon"
    task :stop_calendar_smf, :roles => :app do
      sudo "svcadm disable /site/ruby/joyent_calendar_subscriptions"
    end
    
    desc "delete calendar subscription SMF"
    task :delete_calendar_smf, :roles => :app do
      sudo "svccfg delete /site/ruby/joyent_calendar_subscriptions"
    end
    
  end
  
  after 'deploy:setup', 'joyent:copy_configs_to_shared'
  after 'deploy:update_code', 'joyent:copy_configs'
  before 'deploy:symlink', 'joyent:remove_current_dir'
  after 'deploy:symlink', 'joyent:cat_assets'
  after 'deploy:start', 'joyent:start_joyent_job' # before 'deploy:start' ?
  after 'deploy:stop', 'joyent:stop_joyent_job'
  before 'deploy', 'joyent:stop_joyent_job'
  after 'deploy', 'joyent:start_joyent_job'
  after 'deploy', 'joyent:gmime'
  # Calendar subscriptions daemon:
  after 'deploy:setup', 'joyent:calendar_smf'
  after 'deploy:cold', 'joyent:import_calendar_smf'
  after 'deploy:stop', 'joyent:stop_calendar_smf'
  after 'deploy:start', 'joyent:start_calendar_smf'
  before 'deploy', 'joyent:stop_calendar_smf'
  after 'deploy', 'joyent:start_calendar_smf'

end
