#!/usr/bin/env bash

# Usage: Scripts/environment-check.sh
#
# Checks aspects of your development environment for common errors.

# If this is being run on CI, then no need to continue.
if [ -n "$CI" ]; then
    exit 0
fi

set -e

# Checks to be run on devs' machines only:
if [ ! -h .git/hooks/pre-commit ]; then
    echo "error: The Git pre-commit hook is not installed. Run Scripts/bootstrap.sh."
    exit 3
fi
