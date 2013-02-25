if defined?(Capistrano)
  Capistrano::Configuration.instance(:must_exist).load do

    namespace :deploy do
      desc <<-DESC
        Export the Procfile and restart application.

        You can override any of these defaults by setting the variables shown below.

        set :foreman_format,      "upstart"
        set :foreman_location,    "/etc/init"
        set :foreman_procfile,    "Procfile"
        set :foreman_app,         application
        set :foreman_user,        user
        set :foreman_log,         "\#{shared_path}/log"
        set :foreman_concurrency, false
      DESC
      task :restart, :roles => :web, :max_hosts => 1 do
        bundle_cmd          = fetch(:bundle_cmd, "bundle")
        foreman_format      = fetch(:foreman_format, "upstart")
        foreman_location    = fetch(:foreman_location, "/etc/init")
        foreman_procfile    = fetch(:foreman_procfile, "Procfile")
        foreman_app         = fetch(:foreman_app, application)
        foreman_user        = fetch(:foreman_user, user)
        foreman_port        = fetch(:foreman_port, 5000)
        foreman_log         = fetch(:foreman_log, "#{shared_path}/log")
        foreman_concurrency = fetch(:foreman_concurrency, false)

        args = ["#{foreman_format} #{foreman_location}"]
        args << "-f #{foreman_procfile}"
        args << "-a #{foreman_app}"
        args << "-u #{foreman_user}"
        args << "-l #{foreman_log}"
        args << "-p #{foreman_port}"
        args << "-c #{foreman_concurrency}" if foreman_concurrency
        export_cmd = "cd #{current_path} && #{bundle_cmd} exec foreman export #{args.join(' ')}"
        run ["sudo /etc/init.d/puppet stop",
            "sudo /etc/init.d/monit stop",  
            "sudo /etc/init.d/nginx stop",
            "monit stop -g #{application}", 
            export_cmd, 
            "monit start -g #{application}",
            "sleep 15", 
            "sudo /etc/init.d/nginx start",
            "sudo /etc/init.d/monit start", 
            "sudo /etc/init.d/puppet start"].join('; ')
            "sleep 5", 
      end
    end
  end
end

