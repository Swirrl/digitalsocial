# -*- coding: utf-8 -*-
require 'bundler/capistrano' # enable bundler stuff!

set :stages, %w(app staging holding)
set :default_stage, "app"
require 'capistrano/ext/multistage'

load 'deploy/assets'

# rvm stuff
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
set :rvm_ruby_string, '1.9.3-p194'        # Or whatever env you want it to run in.
set :rvm_type, :user
###

server "176.9.106.113", :app, :web, :db, :primary => true

set(:deploy_to) { File.join("", "home", user, "sites", application) }

default_run_options[:pty] = true

ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "id_rsa")]

set :repository,  "git@github.com:Swirrl/digitalsocial.git"
set :scm, "git"
set :ssh_options, {:forward_agent => true, :keys => "~/.ssh/id_rsa" }
set :user, "rails"
set :runner, "rails"
set :admin_runner, "rails"
set :use_sudo, false

set :deploy_via, :remote_cache

after 'deploy:setup', 'deploy:make_shared_config_dir'
after 'deploy:setup', 'deploy:transfer_production_config'
before 'deploy:assets:precompile', 'deploy:remove_example_secret_token_rb'
before 'deploy:assets:precompile', 'deploy:symlink_shared_config'

namespace :deploy do

  task :make_shared_config_dir do
    run "mkdir #{shared_path}/configs"
  end

  desc 'Copy the production config files to the shared folder - so they can be symlinked in later'
  task :transfer_production_config do
    top.upload(File.join('config', 'mongoid.yml'),
               File.join(shared_path, 'configs', 'mongoid.yml'))

    top.upload(File.join('config','s3.yml'),
               File.join(shared_path, 'configs', 's3.yml'))

    top.upload(File.join('config', 'initializers', 'secret_token_production.rb'),
               File.join(shared_path, 'configs', 'secret_token.rb'))

    top.upload(File.join('config', 'environments', 'production.rb'),
               File.join(shared_path, 'configs', 'production.rb'))
  end

  task :symlink_shared_config do
    run("ln -s " + File.join(shared_path,  'configs', 'mongoid.yml') + " " +
                   File.join(release_path, 'config', 'mongoid.yml'))

    run("ln -s " + File.join(shared_path,  'configs', 's3.yml') + " " +
                   File.join(release_path, 'config', 's3.yml'))

    secret_token_rb = File.join(release_path, 'config', 'initializers', 'secret_token.rb')
    run("rm " + secret_token_rb)
    run("ln -s " + File.join(shared_path,  'configs', 'secret_token.rb') + " " +
                   secret_token_rb)


    run("ln -s " + File.join(shared_path,  'configs', 'production.rb') + " " +
                   File.join(release_path, 'config', 'environments', 'production.rb'))
  end

  task :remove_example_secret_token_rb do
    run("rm " + File.join(release_path, 'config', 'initializers', 'secret_token_production_example.rb'))
  end

  desc <<-DESC
    overriding deploy:cold task to not migrate...
  DESC
  task :cold do
    update
    start
  end

  desc <<-DESC
    overriding start to just call restart
  DESC
  task :start do
    restart
  end

  desc <<-DESC
    overriding stop to do nothing - you cant stop a passenger app!
  DESC
  task :stop do
  end

  desc <<-DESC
    overriding start to just touch the restart txt
  DESC
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
    # No caching at the mo.
  #  sudo "echo 'flush_all' | nc localhost 11212" # flush memcached
  end
end

require './config/boot'
