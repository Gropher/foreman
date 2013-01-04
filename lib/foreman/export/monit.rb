require 'foreman/export'
require 'foreman/cli'

class Foreman::Export::Monit < Foreman::Export::Base
  attr_reader :pid, :check

  def export
    super

    @user ||= app
    @log = File.expand_path("#{@location}/log")
    @pid = File.expand_path("#{@location}/pids")
    @check = File.expand_path("#{@location}/lock")
    @location = File.expand_path(@location)
    FileUtils.mkdir_p(@pid)
    FileUtils.mkdir_p(@check)

    engine.each_process do |name, process|
      write_template "monit/wrapper.sh.erb", "#{app}-#{name}.sh", binding
      chmod 0755, "#{app}-#{name}.sh"
      `touch #{check_file_for(name)}`
    end

    `touch #{app_check_file}`
    write_template "monit/monitrc.erb", "#{app}.monitrc", binding
  end

  def wrapper_path_for(name)
    File.join(location, "#{app}-#{name}.sh")
  end

  def pid_file_for(name, num)
    File.join(pid, "#{app}-#{name}-#{num}.pid")
  end

  def log_file_for(name, num)
    File.join(log, "#{app}-#{name}-#{num}.log")
  end

  def check_file_for(name)
    File.join(check, "#{app}-#{name}.restart")
  end

  def app_check_file
    File.join(check, "#{app}.restart")
  end
end
