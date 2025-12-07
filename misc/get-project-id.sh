 
function get-project-id() {
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
  
}

export -f get-project-id
