// Package v1beta1 contains the input type for this Function
// +kubebuilder:object:generate=true
// +groupName=xvpn.fn.crossplane.io
// +versionName=v1beta1
package v1beta1

import (
    metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// Input is the input for the function
// +kubebuilder:object:root=true
type Input struct {
    metav1.TypeMeta   `json:",inline"`
    metav1.ObjectMeta `json:"metadata,omitempty"`

    // VMUser is the SSH username for the VM
    VMUser string `json:"vmUser"`

    // PublicKey is the SSH public key
    PublicKey string `json:"publicKey"`

    // Zone is the GCP zone (optional, defaults in composition)
    // +optional
    Zone string `json:"zone,omitempty"`

    // MachineType is the GCP machine type (optional, defaults in composition)
    // +optional
    MachineType string `json:"machineType,omitempty"`
}
