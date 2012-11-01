class RComp
  module Actions
    
    def rm_rf(directory)
      if File.exist? directory
        FileUtils.rm_rf directory
        say "Removed #{directory} and all subdirectories"
      end
    end

    def rm(file)
      if File.exist? file
        FileUtils.rm file
        say "Removed #{file}"
      end
    end

    def mkdir(path)
      unless File.exist? path
        FileUtils.mkdir path
        say "Created #{path}"
      end
    end

    def touch(path)
      unless File.exist? path
        FileUtils.touch path
        say "Created #{path}"
      end
    end

    def write_config_file
      touch '.config'

      config_file = File.open '.config'
      config_file.puts YAML.dump data
    end
  end
end
