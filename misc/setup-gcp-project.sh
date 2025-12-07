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

# Normalize project name to valid ID format (for pattern matching)
PROJECT_ID_BASE=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-//;s/-$//')

# Ensure it starts with a letter
if ! [[ "$PROJECT_ID_BASE" =~ ^[a-z] ]]; then
  PROJECT_ID_BASE="p-$PROJECT_ID_BASE"
fi

# Truncate to 24 chars
PROJECT_ID_BASE="${PROJECT_ID_BASE:0:24}"
PROJECT_ID_BASE=$(echo "$PROJECT_ID_BASE" | sed 's/-$//')  # Remove trailing dash if any

echo "=== GCP Project Setup ==="
echo "Project Name: $PROJECT_NAME"
echo "Searching for existing projects matching: $PROJECT_ID_BASE-*"
echo ""

# --- Authentication ---
echo "Checking authentication..."
if ./gcloud.sh auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null | grep -q "@"; then
  ACTIVE_ACCOUNT=$(./gcloud.sh auth list --filter=status:ACTIVE --format="value(account)" | head -n 1)
  echo "✓ Already authenticated as: $ACTIVE_ACCOUNT"
else
  echo "No active authentication found. Initiating login..."
  ./gcloud.sh auth login --no-launch-browser
  echo "✓ Authentication complete"
fi

echo ""

# --- Check for existing projects matching the pattern ---
echo "Checking for existing projects..."
EXISTING_PROJECT=$(./gcloud.sh projects list --filter="projectId:$PROJECT_ID_BASE-* AND name:$PROJECT_NAME" --format="value(projectId)" 2>/dev/null | head -n 1 | tr -d '\r\n\t ' || true)

if [ -n "$EXISTING_PROJECT" ]; then
  PROJECT_ID="$EXISTING_PROJECT"
  echo "✓ Found existing project: $PROJECT_ID"
  PROJECT_EXISTS=true
else
  # Generate new project ID with random suffix
  RANDOM_SUFFIX=$(head /dev/urandom | tr -dc 'a-z0-9' | head -c 4)
  PROJECT_ID="${PROJECT_ID_BASE}-${RANDOM_SUFFIX}"
  
  # Ensure final ID meets length requirements (6-30 chars)
  if [ ${#PROJECT_ID} -lt 6 ]; then
    PROJECT_ID="${PROJECT_ID}-$(head /dev/urandom | tr -dc 'a-z0-9' | head -c $((6 - ${#PROJECT_ID})))"
  fi
  
  echo "No existing project found"
  echo "Generated Project ID: $PROJECT_ID"
  PROJECT_EXISTS=false
fi

# Strip any whitespace/carriage returns from PROJECT_ID
PROJECT_ID=$(echo "$PROJECT_ID" | tr -d '\r\n\t ')

echo ""

# --- Create project if it doesn't exist ---
if [ "$PROJECT_EXISTS" = false ]; then
  echo "Creating project '$PROJECT_ID' with name '$PROJECT_NAME'..."
  
  if ./gcloud.sh projects create "$PROJECT_ID" --name="$PROJECT_NAME"; then
    echo "✓ Project '$PROJECT_ID' created successfully"
  else
    echo "✗ Error: Failed to create project"
    exit 1
  fi
  echo ""
fi

# --- Set the project as default ---
echo "Setting '$PROJECT_ID' as the default project..."
./gcloud.sh config set project "$PROJECT_ID" >/dev/null 2>&1
echo "✓ Default project set to '$PROJECT_ID'"

echo ""

# --- Check and enable billing if needed ---
echo "Checking billing status..."
BILLING_ENABLED=$(./gcloud.sh billing projects describe "$PROJECT_ID" --format="value(billingEnabled)" 2>/dev/null || echo "false")

if [ "$BILLING_ENABLED" = "True" ]; then
  BILLING_ACCOUNT=$(./gcloud.sh billing projects describe "$PROJECT_ID" --format="value(billingAccountName)" 2>/dev/null)
  echo "✓ Billing already enabled ($BILLING_ACCOUNT)"
  BILLING_SUCCESS=true
else
  echo "Enabling billing..."
  
  # Get the first open billing account with full path
  BILLING_ACCOUNT_FULL=$(./gcloud.sh billing accounts list --filter="open=true" --format="value(name)" 2>/dev/null | head -n 1 | tr -d '\r\n\t ')
  
  if [ -n "$BILLING_ACCOUNT_FULL" ]; then
    BILLING_ACCOUNT_ID=$(echo "$BILLING_ACCOUNT_FULL" | sed 's/billingAccounts\///')
    echo "  Using billing account: $BILLING_ACCOUNT_ID"
    
    # Use explicit command without variable interpolation issues
    if OUTPUT=$(./gcloud.sh billing projects link "$PROJECT_ID" --billing-account="$BILLING_ACCOUNT_FULL" 2>&1); then
      echo "✓ Billing enabled successfully"
      BILLING_SUCCESS=true
    else
      echo "✗ Failed to enable billing"
      echo "$OUTPUT"
      echo "  Enable manually at: https://console.cloud.google.com/billing/linkedaccount?project=$PROJECT_ID"
      BILLING_SUCCESS=false
    fi
  else
    echo "✗ No billing accounts found"
    echo "  Create one at: https://console.cloud.google.com/billing"
    BILLING_SUCCESS=false
  fi
fi

