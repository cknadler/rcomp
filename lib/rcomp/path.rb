module RComp
  module Path

    def rel_path(test_path)
      test_path.gsub(Conf.instance.test_root, '')
    end
  end
end
