# xp-base

Welcome to **xp-base**, a bootstrap-style repository to help you quickly get started with Crossplane projects — including support for xp-functions. With this repo you can deploy a minimal working infrastructure on Google Cloud Platform (GCP), making it easier to experiment with Crossplane, manage cloud resources, and test out xp-functions in a controlled, script-driven environment.

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

