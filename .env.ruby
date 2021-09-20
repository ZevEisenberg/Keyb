# Adapted from https://mgrebenets.github.io/xcode/2019/04/04/xcode-build-phases-and-environment

export PATH="$HOME/.rvm/bin:$HOME/.rbenv/shims:$PATH" # Add rvm and rbenv to PATH for scripting.

# Read Ruby version for the project from .ruby-version.
RUBY_VERSION="$(cat .ruby-version)"
