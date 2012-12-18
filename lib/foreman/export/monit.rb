require 'foreman/export'
require 'foreman/cli'

module Foreman
  module Export
    class Monit < Foreman::Export::Base
      attr_reader :pid, :check

      def initialize(location, engine, options={})
        super
        @pid = options[:pid]
        @check = options[:check]
      end

      def export
        super

        @user ||= app
        @log = File.expand_path(@log || "/var/log/#{app}")
        @pid = File.expand_path(@pid || "/var/run/#{app}")
        @check = File.expand_path(@check || "/var/lock/subsys/#{app}")
        @location = File.expand_path(@location)

        engine.procfile.entries.each do |process|
          write_template "monit/wrapper.sh.erb", "#{app}-#{process.name}.sh", binding
        end

        write_template "monit/monitrc.erb", "#{app}.monitrc", binding
      end

      def wrapper_path_for(process)
        File.join(location, "#{app}-#{process.name}.sh")
      end

      def pid_file_for(process, num)
        File.join(pid, "#{process.name}-#{num}.pid")
      end

      def log_file_for(process, num)
        File.join(log, "#{process.name}-#{num}.log")
      end

      def check_file_for(process)
        File.join(check, "#{process.name}.restart")
      end
    end
  end
end
