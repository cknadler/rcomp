# external
require 'aruba/api'

# stdlib
require 'fileutils'

Given /^an executable named "([^"]*)" with:$/ do |file_name, file_content|
  write_file(file_name, file_content)
  in_current_dir do
    FileUtils.chmod 0755, file_name
  end
end

Then /^the files "(.*?)" and "(.*?)" should be identical$/ do |file1, file2|
  FileUtils.identical?(file1, file2).should eq true
end
