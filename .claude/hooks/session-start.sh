#!/bin/bash
# Gets a fresh Claude Code cloud session ready to work on Inkwll:
# starts PostgreSQL, installs gems, and sets up the databases.
# Only runs in cloud sessions; does nothing on your own computer.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd "$CLAUDE_PROJECT_DIR"

# Use the Ruby version this project asks for.
RUBY_BIN="/opt/rbenv/versions/$(sed 's/^ruby-//' .ruby-version)/bin"
if [ -d "$RUBY_BIN" ]; then
  export PATH="$RUBY_BIN:$PATH"
  echo "export PATH=\"$RUBY_BIN:\$PATH\"" >> "$CLAUDE_ENV_FILE"
fi

# Start the database and let the current user (root) connect to it.
service postgresql start > /dev/null
if ! su postgres -c "psql -tAc \"SELECT 1 FROM pg_roles WHERE rolname='$(whoami)'\"" | grep -q 1; then
  su postgres -c "psql -c 'CREATE ROLE \"$(whoami)\" SUPERUSER LOGIN'" > /dev/null
fi

# Install gems (skipped quickly if they are already installed).
bundle check > /dev/null || bundle install

# Create or update the development and test databases.
bin/rails db:prepare
RAILS_ENV=test bin/rails db:prepare
