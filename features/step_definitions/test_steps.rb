require 'aruba/api'

Given /^an executable named "([^"]*)" with:$/ do |file_name, file_content|
  write_file(file_name, file_content)
  in_current_dir do
    FileUtils.chmod 0755, file_name
  end
end

Then /^the file "(.*?)" matches "(.*?)" exactly$/ do |file1, file2|
  FileUtils.identical?(file1, file2).should eq true
end
