#!/usr/bin/env bash

set -e

"$(git rev-parse --show-toplevel)"/Scripts/lint.sh
