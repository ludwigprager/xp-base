function enable-billing() {
  PROJECT_ID=$(./gcloud.sh config get-value project)
  
  echo "Checking billing status..."
  BILLING_ENABLED=$(./gcloud.sh billing projects describe "$PROJECT_ID" --format="value(billingEnabled)" 2>/dev/null || echo "false")
  
  if [ "$BILLING_ENABLED" = "True" ]; then
    BILLING_ACCOUNT=$(./gcloud.sh billing projects describe "$PROJECT_ID" --format="value(billingAccountName)" 2>/dev/null)
    echo "✓ Billing already enabled ($BILLING_ACCOUNT)"
    BILLING_SUCCESS=true
  else
    echo "Enabling billing..."
    
    # Get billing account ID
    BILLING_ACCOUNT_ID=$(./gcloud.sh billing accounts list --filter="open=true" --format="value(name)" 2>/dev/null | head -n 1 | sed 's|billingAccounts/||' | tr -d '\r\n\t ')
    
    if [ -n "$BILLING_ACCOUNT_ID" ]; then
      echo "  Using billing account: $BILLING_ACCOUNT_ID"
      
      # Check if we have permission
      echo "  Checking permissions..."
      if ! ./gcloud.sh billing accounts get-iam-policy "$BILLING_ACCOUNT_ID" &>/dev/null; then
        echo "⚠ Cannot access billing account IAM policy"
      fi
      
      # Try linking with explicit format
      echo "  Attempting to link billing..."
      if OUTPUT=$(./gcloud.sh beta billing projects link "$PROJECT_ID" --billing-account="$BILLING_ACCOUNT_ID" 2>&1); then
        echo "  Link command output: $OUTPUT"
      else
        echo "  Link command failed: $OUTPUT"
      fi
      
      # Verify
      sleep 3
      BILLING_CHECK=$(./gcloud.sh billing projects describe "$PROJECT_ID" --format="value(billingEnabled)" 2>/dev/null || echo "false")
      
      if [ "$BILLING_CHECK" = "True" ]; then
        echo "✓ Billing verified as enabled"
        BILLING_SUCCESS=true
      else
        echo "✗ Billing link failed"
        echo ""
        echo "Please enable billing manually:"
        echo "  https://console.cloud.google.com/billing/linkedaccount?project=$PROJECT_ID"
        echo ""
        echo "Or run this command manually:"
        echo "  gcloud billing projects link $PROJECT_ID --billing-account=$BILLING_ACCOUNT_ID"
        BILLING_SUCCESS=false
      fi
    else
      echo "✗ No billing accounts found"
      BILLING_SUCCESS=false
    fi
  fi
}
export -f enable-billing
