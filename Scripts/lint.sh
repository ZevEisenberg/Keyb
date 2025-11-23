#!/usr/bin/env bash

set -e

scriptPath="$(git rev-parse --show-toplevel)/Scripts"
export scriptPath

if [ ! -f "${scriptPath}/_lint.sh" ]; then
    echo "Please run Scripts/bootstrap.sh"
    exit 1
fi

"${scriptPath}"/_lint.sh
