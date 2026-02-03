#!/usr/bin/env bash

set -euo pipefail

if [ -n "${GIT_AUTHOR_NAME:-}" ]; then
        git config --global user.name "$GIT_AUTHOR_NAME"
fi

if [ -n "${GIT_AUTHOR_EMAIL:-}" ]; then
        git config --global user.email "$GIT_AUTHOR_EMAIL"
fi

if [ -n "${GIT_SIGNING_KEY:-}" ]; then
        git config --global user.signingkey "$GIT_SIGNING_KEY"
fi

if [ -n "${GIT_GPGSIGN:-}" ]; then
        git config --global commit.gpgsign "$GIT_GPGSIGN"
fi
