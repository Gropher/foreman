require 'foreman/export'
require 'foreman/cli'

module Foreman
  module Export
    class Monit < Foreman::Export::Base
      attr_reader :pid, :check

      def export
        super

        @user ||= app
        @log = File.expand_path("#{@location}/log")
        @pid = File.expand_path("#{@location}/pid")
        @check = File.expand_path("#{@location}/lock")
        @location = File.expand_path(@location)
        FileUtils.mkdir_p(@pid)
        FileUtils.mkdir_p(@check)

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
