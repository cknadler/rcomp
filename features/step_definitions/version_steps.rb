require 'aruba/api'
require 'rcomp/version'

Then /^the output should contain the version number$/ do
  expected = "RComp version #{RComp::VERSION}\n"
  assert_exact_output(expected, all_output)
end
