module Path
  def relative_path(test_path)
    test_path.gsub(@conf.test_root, '')
  end

  def result_path(test_path)
    @conf.result_root + relative_path(test_path)
  end

  def expected_path(test_path)
    @conf.expected_root + relative_path(test_path)
  end
end
