class RComp
  module Actions
    
    def rm_rf(directory)
      if File.exist? directory
        system "rm -rf #{directory}"
        say "Removed #{directory} and all subdirectories"
      end
    end

    def rm(file)
      if File.exist? file
        system "rm #{file}"
        say "Removed #{file}"
      end
    end

    def mkdir(path)
      unless File.exist? path
        system "mkdir #{path}" 
        say "Created #{path}"
      end
    end
  end
end
