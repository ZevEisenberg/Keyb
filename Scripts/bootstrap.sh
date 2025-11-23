#!/usr/bin/env bash

set -e

basePath="$(git rev-parse --show-toplevel)"

if [ -h .git/hooks/pre-commit ]; then
    rm .git/hooks/pre-commit
fi

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
