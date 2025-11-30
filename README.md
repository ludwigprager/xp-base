# xp-base

Welcome to **xp-base**, a bootstrap-style repository to help you quickly get started with Crossplane projects — including support for xp-functions. With this repo you can deploy a minimal working infrastructure on Google Cloud Platform (GCP), making it easier to experiment with Crossplane, manage cloud resources, and test out xp-functions in a controlled, script-driven environment.

# TL;DR

Install docker compose and podman, choose a GCP project which can be empty.

```
# clone the repo
git clone -o github https://github.com/ludwigprager/xp-base.git 
```

Tell it your GCP project id:
```
export XP_BASE_GCP_PROJECT=my-gcp-project-123456
```

Execute the deployment
```
./xp-base/10-deploy.sh
```


---

## ✅ Goals

- Pin versions where possible (e.g. `kind`, Node, Crossplane, provider versions).  
- Keep the setup self-contained: installed binaries are placed in the working directory.  
- Avoid modifying the user’s host environment: e.g. the GCP CLI runs inside a container (via Podman) if available.  
- Easy cleanup / rollback: the `90-teardown.sh` script removes created resources; deleting the working directory deletes most footprints (except logs or local container images).  
- Idempotent scripts — you can (re)run them without causing unexpected side effects.

---

## 🔧 Prerequisites

Before using xp-base, ensure you have:

- A **Linux OS** (or compatible shell environment)  
- **Docker** and **Podman** installed  
- Internet connectivity (to download required binaries, container images, and access GCP)  
- A working **GCP account and project** — authentication via your user account suffices.  
- The GCP project name must be stored in the environment variable:

  ```bash
  export XP_BASE_GCP_PROJECT=my-gcp-project-123456


## Common Pitfalls and Solutions

### 1. Using a Private FQDN for the Internal Registry

**Problem**  
This project is designed to operate in a **self-contained and isolated environment** (“POT”).  
Because external network access is not allowed, the system **cannot use public container registries** such as `docker.io`, `quay.io`, or GitHub Container Registry.  
All images must be pulled from a **local private registry**, typically exposed under an internal FQDN such as:

```
registry.g1
```

Kubernetes, Docker, and build systems, however, **do not automatically trust or resolve custom registry hostnames**.  
Common symptoms include:

- `ImagePullBackOff` in Kubernetes  
- `x509: certificate signed by unknown authority`  
- Docker refusing to push:  
  ```
  server gave HTTP response to HTTPS client
  ```  
- Build tools (buildx/dind) silently failing to push to the registry

---

### Cause  
Kubernetes components (kubelet, container runtime, kind nodes, builders) expect registries to:

- be resolvable,  
- be trusted,  
- use TLS unless explicitly marked insecure,  
- be explicitly listed as allowed registry sources.

A custom internal FQDN such as `registry.g1` is **not recognized unless explicitly configured**.

---

### Solution

To use an internal FQDN registry in an isolated environment:

#### A) Ensure the hostname resolves everywhere

Add to `/etc/hosts` for your host *and* for any VMs/containers/builders that need access:

```
<host-ip> registry.g1
```

Example for local development:

```
127.0.0.1 registry.g1
```

For Docker containers:

```yaml
extra_hosts:
  - "registry.g1:host-gateway"
```

---

#### B) Mark the registry as insecure (if using plain HTTP)

Most isolated environments run a registry without TLS.  
Docker, containerd, and Kubernetes require explicit opt-in.

For Docker daemon:

```json
"insecure-registries": ["registry.g1:5000"]
```

For containerd (Kind nodes):

```toml
[plugins."io.containerd.grpc.v1.cri".registry.mirrors."registry.g1"]
  endpoint = ["http://registry.g1:5000"]
```

---

#### C) Ensure builders (docker buildx / dind) are configured

If you’re using Docker-in-Docker to build images:

```yaml
command: ["--insecure-registry", "registry.g1:5000"]
```

Or when building with Buildx:

```bash
docker buildx build --push   --tlsverify=false   -t registry.g1/myimage:latest .
```

---

#### D) Use the FQDN in all image references

Kubernetes must pull images using the registry’s full FQDN:

```yaml
image: registry.g1/my-service:1.0.0
```

Local images must be tagged accordingly:

```bash
docker tag my-service:latest registry.g1/my-service:latest
docker push registry.g1/my-service:latest
```

---

### Summary

Because the project is intentionally isolated and must operate without internet access, a **local registry with a private FQDN** is required.  
To avoid image pull failures:

1. Ensure the FQDN resolves everywhere  
2. Mark it as an insecure registry (when running HTTP)  
3. Configure Kind/containerd and builder containers  
4. Use the FQDN consistently in image names  

Once everything trusts `registry.g1`, Kubernetes can pull images successfully within the isolated environment.

