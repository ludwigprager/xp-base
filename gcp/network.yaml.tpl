---

apiVersion: compute.gcp.upbound.io/v1beta1
kind: Firewall
metadata:
  name: allow-wireguard
spec:
  forProvider:
    network: default
    direction: INGRESS
    priority: 1000
    allow:
      - protocol: udp
        ports:
          - "51820"
      - protocol: tcp
        ports:
          - "80"
          - "443"
    sourceRanges:
      - "0.0.0.0/0"  # Allow from anywhere - restrict this for production!
    targetTags:
      - wireguard-server  # Apply to VMs with this tag
    description: "Allow WireGuard VPN traffic on UDP port 51820"
  providerConfigRef:
    name: default
  managementPolicies:
    - "*"
