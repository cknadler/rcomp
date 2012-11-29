require 'childprocess'

module RComp
  class Process

    include RComp::Actions

    # Initialize a new process
    #
    # cmd - An array of shellwords of a command
    # timeout - Time until the process is automatically killed
    # out - Path to send stdout of process
    # err - Path to send stderr of process
    def initialize(cmd, timeout, out, err)
      @timeout = timeout
      @process = ChildProcess.build(*cmd)
      @process.io.stdout = File.new(out, 'w')
      @process.io.stderr = File.new(err, 'w')
    end

    # Runs a process and with a specified command and timeout
    #
    # Returns nothing
    def run
      begin 
        @process.start
      rescue ChildProcess::LaunchError => e
        raise StandardError.new(e.message)
      end

      begin 
        @process.poll_for_exit(@timeout)
      rescue ChildProcess::TimeoutError
        @timedout = true
        @process.stop(@timeout)
      end
    end

    # Check if the proccess timed out or not
    #
    # Returns a boolean
    def timedout?
      @timedout ||= false
    end
  end
end
