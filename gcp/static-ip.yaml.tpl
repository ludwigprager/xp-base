---

apiVersion: compute.gcp.upbound.io/v1beta1
kind: Address
metadata:
  name: ${GCP_VM_ZONE}-0  # Fixed: was "name:  zone:"
spec:
  forProvider:
    region: ${GCP_VM_REGION}  # Fixed: needs region, not zone (e.g., us-central1, not us-central1-a)
    description: "Static IP for ${GCP_VM_NAME}"
    addressType: EXTERNAL
#   networkTier: PREMIUM
    networkTier: STANDARD
  providerConfigRef:
    name: default
