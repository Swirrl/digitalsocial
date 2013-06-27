require 'bundler/capistrano' # enable bundler stuff!
require "delayed/recipes"
load 'deploy/assets'

# rvm stuff
$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
set :rvm_ruby_string, '1.9.3-p194'        # Or whatever env you want it to run in.
set :rvm_type, :user
###

set :application, "digitalsocial"

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

set :branch, "master"

set :deploy_via, :remote_cache

# delayed job hooks.
after "deploy:stop",    "delayed_job:stop"
after "deploy:start",   "delayed_job:start"
after "deploy:restart", "delayed_job:restart"

namespace :deploy do

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
    sudo "echo 'flush_all' | nc localhost 11212" # flush memcached
  end
end

require './config/boot'
