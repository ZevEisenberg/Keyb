# Adapted from https://mgrebenets.github.io/xcode/2019/04/04/xcode-build-phases-and-environment

export PATH="$HOME/.rvm/bin:$PATH" # Add RVM to PATH for scripting. 

# Read Ruby version for the project from .ruby-version. 
RUBY_VERSION="$(cat .ruby-version)" 

# Source the Ruby environment for selected Ruby version. 
source "$(rvm "${RUBY_VERSION}" do rvm env --path | tail -n1)"
