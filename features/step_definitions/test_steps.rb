require 'aruba/api'

When /^I run `(.*?)` for up to (\d+) seconds$/ do |cmd, secs|
  run_simple(unescape(cmd), false, secs && secs.to_i)
end

When /^I remove the directory "(.*?)"$/ do |file|
  in_current_dir do
    FileUtils.rm_rf(file)
  end
end
