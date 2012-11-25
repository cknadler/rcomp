require 'aruba/api'

When /^I run `(.*?)` for up to (\d+) seconds$/ do |cmd, secs|
  run_simple(unescape(cmd), false, secs && secs.to_i)
end
