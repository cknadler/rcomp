module RComp
  module Path
    def rel_path(test_path)
      test_path.gsub(Conf.instance.test_root, '')
    end

    def result_path(test_path, type)
      cmpnts = []
      cmpnts << Conf.instance.result_root
      cmpnts << rel_path(File.dirname(test_path))
      cmpnts << File.basename(test_path, ".*") + (type == :out ? '.out' : '.err')
      File.join(cmpnts)
    end

    def expected_path(test_path, type)
      puts Conf.instance.expected_root
      puts rel_path(File.dirname(test_path))
      puts File.basename(test_path, ".*") + (type == :out ? '.out' : '.err')

      cmpnts = []
      cmpnts << Conf.instance.expected_root
      cmpnts << rel_path(File.dirname(test_path))
      cmpnts << File.basename(test_path, ".*") + (type == :out ? '.out' : '.err')
      puts File.join(cmpnts)
      File.join(cmpnts)
    end
  end
end
