# Adapted from https://mgrebenets.github.io/xcode/2019/04/04/xcode-build-phases-and-environment
# And further modified to switch from rvm to rbenbv

export PATH="$HOME/.rbenv/shims:$PATH" # Add rbenv to PATH for scripting.

# Set up rbenv
eval "$(rbenv init -)"
