# https://cloud.google.com/compute/vm-instance-pricing#shared-core-machine-types
# https://marketplace.upbound.io/providers/upbound/provider-gcp-compute/v2.2.0/resources/compute.gcp.m.upbound.io/Instance/v1beta1#doc:spec-forProvider


apiVersion: compute.gcp.upbound.io/v1beta2
kind: Instance
metadata:
  name: wg-vm
spec:
  forProvider:
    zone: ${GCP_VM_ZONE}
    machineType: e2-medium

    bootDisk:
      autoDelete: true
      initializeParams:
        image: debian-cloud/debian-12

    networkInterface:
      - network: default
        accessConfig:
          - {}  # ephemeral external IP

    metadata:
      ssh-keys: "${VM_USER}:${PUBLIC_KEY}"

  providerConfigRef:
    name: default

