require 'mongrel_cluster/recipes'

set :application, "listlibrary.net"

set :scm, :git
set :repository, "harkins@argyle.redirectme.net:~/biz/listlibrary"

set :deploy_to, "/home/listlibrary/listlibrary.net"
set :deploy_via, :copy

set :user, "listlibrary"
set :domain, "tron.dreamhost.com"
set :use_sudo, false
set :ssh_options, { :forward_agent => true }
set :spinner_user, nil

role :web, "listlibrary.net"
role :app, "listlibrary.net"
role :db, "listlibrary.net"

namespace :deploy do
  desc "Restarting Passenger with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/listlibrary.net/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "Task '#{t}' is unneeded with Passenger"
    task t, :roles => :app do ; end
  end
end
