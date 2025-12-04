package main

import (
    "context"
    "fmt"

    "github.com/crossplane/crossplane-runtime/v2/pkg/logging"
    fnv1 "github.com/crossplane/function-sdk-go/proto/v1"
    "github.com/crossplane/function-sdk-go/request"
    "github.com/crossplane/function-sdk-go/response"
    "github.com/crossplane/function-sdk-go/resource"
    "github.com/crossplane/function-sdk-go/resource/composed"

    "gitea.g1/crossplane/function-xvpn/input/v1beta1"
)

type Function struct {
    fnv1.UnimplementedFunctionRunnerServiceServer
    log logging.Logger
}

func (f *Function) RunFunction(_ context.Context, req *fnv1.RunFunctionRequest) (*fnv1.RunFunctionResponse, error) {
    f.log.Info("Running function", "tag", req.GetMeta().GetTag())

    rsp := response.To(req, response.DefaultTTL)

    // Parse input
    input := &v1beta1.Input{}
    if err := request.GetInput(req, input); err != nil {
        response.Fatal(rsp, err)
        return rsp, nil
    }

    // Create the ssh-keys metadata value
    sshKeys := fmt.Sprintf("%s:%s", input.VMUser, input.PublicKey)

    // Set defaults if not provided
    zone := input.Zone
    if zone == "" {
        zone = "us-central1-a"
    }
    machineType := input.MachineType
    if machineType == "" {
        machineType = "e2-medium"
    }

    // Create the GCP Instance as composed resource
    instance := composed.New()

    instance.SetAPIVersion("compute.gcp.upbound.io/v1beta2")
    instance.SetKind("Instance")
    instance.SetName("wg-vm")

    // Set spec
    spec := map[string]interface{}{
        "forProvider": map[string]interface{}{
            "zone":        zone,
            "machineType": machineType,
            "bootDisk": map[string]interface{}{
                "autoDelete": true,
                "initializeParams": map[string]interface{}{
                    "image": "debian-cloud/debian-12",
                },
            },
            "networkInterface": []interface{}{
                map[string]interface{}{
                    "network": "default",
                    "accessConfig": []interface{}{
                        map[string]interface{}{},
                    },
                },
            },
            "metadata": map[string]interface{}{
                "ssh-keys": sshKeys,
            },
        },
        "providerConfigRef": map[string]interface{}{
            "name": "default",
        },
    }

    if err := instance.SetValue("spec", spec); err != nil {
        response.Fatal(rsp, err)
        return rsp, nil
    }

    // Add to desired resources using the correct types
    desired := map[resource.Name]*resource.DesiredComposed{
        "wg-vm": {Resource: instance},
    }

    if err := response.SetDesiredComposedResources(rsp, desired); err != nil {
        response.Fatal(rsp, err)
        return rsp, nil
    }

    return rsp, nil
}
