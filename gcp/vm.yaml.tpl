# https://cloud.google.com/compute/vm-instance-pricing#shared-core-machine-types
# https://marketplace.upbound.io/providers/upbound/provider-gcp-compute/v2.2.0/resources/compute.gcp.m.upbound.io/Instance/v1beta1#doc:spec-forProvider


apiVersion: compute.gcp.upbound.io/v1beta2
kind: Instance
metadata:
  name: ${GCP_VM_NAME}
spec:
  forProvider:
    zone: ${GCP_VM_ZONE}
    machineType: g1-small

    bootDisk:
      autoDelete: true
      initializeParams:
        image: debian-cloud/debian-12

    networkInterface:
      - network: default
        accessConfig:
          - {}  # ephemeral external IP

    tags:
      - wireguard-server  # Match the firewall targetTags

    metadata:
      ssh-keys: "${VM_USER}:${PUBLIC_KEY}"

  providerConfigRef:
    name: default

# managementPolicies:
#   - Observe
#   - Update        # Allow Crossplane to manage after adoption
#   # - LateInitialize (default) if needed

  managementPolicies:
    - "*"  # Full management
