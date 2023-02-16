
apiVersion: gcp.upbound.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  projectID: ${CLOUDSDK_CORE_PROJECT}
  credentials:
    source: Secret
    secretRef:
      namespace: upbound-system
      name: ${GCP_SECRET_NAME}
      key: creds
