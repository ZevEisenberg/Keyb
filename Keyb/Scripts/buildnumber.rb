# Set the build number to the current git commit count.
# If we're using the Debug scheme, then we'll suffix the build
# number with the current branch name, to make collisions
# far less likely across feature branches.

require 'git'
require 'logger'

logger = Logger.new(STDOUT)
logger.level = Logger::WARN
g = Git.open('.', :log => logger)

# pass nil for the count of the log to get all commits:
# https://github.com/ruby-git/ruby-git/issues/182
commit_count = g.log(nil).count

branch_name = g.current_branch
build_number_debug = "#{commit_count}-#{branch_name}"
build_number_release = "#{commit_count}"

xcconfig_contents = %{// Configuration settings file format documentation can be found at:
// https://help.apple.com/xcode/#/dev745c5c974

// Build number is updated by a build script. We prevent further changes to this
// file from being committed by using git update-index --skip-worktree path_to_this_file,
// as described here: https://stackoverflow.com/a/39776107
//
// To commit changes to this file, stop ignoring it with git update-index --no-skip-worktree path_to_this_file

KEYB_BUILD_NUMBER_Debug = #{build_number_debug}
KEYB_BUILD_NUMBER_Release = #{build_number_release}
KEYB_BUILD_NUMBER = $(KEYB_BUILD_NUMBER_$(CONFIGURATION))
}

File.open('./Keyb/Resources/xcconfig/BuildNumber.xcconfig', 'w') { |file|
  file.write(xcconfig_contents)
}
