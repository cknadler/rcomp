# stdlib
require 'fileutils'

class RComp

  module Actions
    def rm_rf(directory)
      if File.exist? directory
        FileUtils.rm_rf directory
      end
    end

    def rm(file)
      if File.exist? file
        FileUtils.rm file
      end
    end

    def mkdir(path)
      unless File.exist? path
        FileUtils.mkdir path
      end
    end

    def mkpath_to(path)
      unless File.exists? path
        FileUtils.mkpath File.dirname(path)
      end
    end

    def touch(path)
      unless File.exist? path
        FileUtils.touch path
      end
    end
  end
end
