#!/usr/bin/env bash

set -e

basePath="$(git rev-parse --show-toplevel)"

if [ -h .git/hooks/pre-commit ]; then
    rm .git/hooks/pre-commit
fi

# Configure Git to ignore the commits listed in this file when displaying file history. As of this writing, this is used to hide the giant lint/format commit.
git config blame.ignoreRevsFile .git-blame-ignore-revs

# Do not reflect changes to this file as Git diffs
git update-index --skip-worktree Keyb/Resources/xcconfig/BuildNumber.xcconfig

# Check if Git-LFS is installed
if ! command -v git-lfs &> /dev/null
then
    echo "Installing Git-LFS."
    brew install git-lfs
fi

# Configure Git-LFS hooks for this repo. Do this every time in case LFS is installed but not configured for this repo.
git lfs install

if ln -sf ../../Scripts/pre-commit.sh .git/hooks/pre-commit; then
    echo "Successfully bootstrapped ✅"
fi
