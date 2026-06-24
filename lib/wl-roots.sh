#!/usr/bin/env bash

ROOT_ENV="$HOME/Wonderland/config/wonderland-roots.env"

if [ -f "$ROOT_ENV" ]; then
  source "$ROOT_ENV"
fi

export WL_AUTHORITY_ROOT="${WL_AUTHORITY_ROOT:-$HOME/Wonderland}"
export WL_WORKSHOP_ROOT="${WL_WORKSHOP_ROOT:-$HOME/Workshop}"
export WL_RUNTIME_ROOT="${WL_RUNTIME_ROOT:-$HOME/Runtime}"
export WL_ARCHIVE_ROOT="${WL_ARCHIVE_ROOT:-$HOME/Archive}"
export WL_MEDIA_ROOT="${WL_MEDIA_ROOT:-$HOME/Media}"

export WL_APPS="$WL_WORKSHOP_ROOT/apps"
export WL_SERVICES="$WL_WORKSHOP_ROOT/services"
