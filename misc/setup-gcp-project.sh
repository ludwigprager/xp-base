#!/usr/bin/env bash
set -euo pipefail

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$BASEDIR"

# Function to display usage information
usage() {
  echo "Usage: $0 <project_name>"
  echo "  <project_name>: Human-readable project name (e.g., 'My XVPN Project')"
  echo ""
  echo "Examples:"
  echo "  $0 'My XVPN Project'"
  echo "  $0 xvpn"
  exit 1
}

# Check if project name is provided
if [ -z "${1:-}" ]; then
  echo "Error: Project name not provided."
  usage
fi

PROJECT_NAME="$1"

source get-project-id.sh
source enable-billing.sh

  echo "Checking authentication..."
  if ./gcloud.sh auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null | grep -q "@"; then
    ACTIVE_ACCOUNT=$(./gcloud.sh auth list --filter=status:ACTIVE --format="value(account)" | head -n 1)
    echo "✓ Already authenticated as: $ACTIVE_ACCOUNT"
  else
    echo "No active authentication found. Initiating login..."
    ./gcloud.sh auth login --no-launch-browser
    echo "✓ Authentication complete"
  fi
 
get-project-id  $PROJECT_NAME 
enable-billing
