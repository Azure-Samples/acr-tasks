# Using an OCI context

The sample below builds a windows image based on an OCI context.

> These are `powershell` commands. 

## Bundle up the context into an OCI Artifact

The context has a simple `Dockerfile` and a `hello.txt`
Use oras to create the context and ensure you are in `context` directory. 

```shell
$REGISTRY="myregistry"
$REGISTRY_LOGIN_SERVER="myregistry.azurecr.io"
cd context
az acr login -n $REGISTRY
oras push $REGISTRY_LOGIN_SERVER/windows/oci-context:latest .
```

## Create an ACR to use the context

Create a base image trigger enabled task with the new context and ensure that you specify the required `--platform`. 

```powershell
$REGISTRY="myregistry"
$REGISTRY_LOGIN_SERVER="myregistry.azurecr.io"
az acr task create `
  --registry $REGISTRY `
  --name ocicontextbuild `
  --platform Windows/amd64 `
  --image "windowsimage:{{.Run.ID}}" `
  --context "oci://$REGISTRY_LOGIN_SERVER/windows/oci-context:latest" `
  --file Dockerfile `
  --commit-trigger-enabled false `
  --base-image-trigger-enabled true
```

## Run the task to build and register the base image

Execute the task to build the container image. 

```powershell
$REGISTRY="myregistry"
az acr task run --name ocicontextbuild --registry $REGISTRY
```

The output should confirm that the base images were identified. 

```
...
- image:
    registry: myregistry.azurecr.io
    repository: windowsimage
    tag: cf1bun
    digest: sha256:90f3c6534f9ed4ed8fa5bdaca006e284f0900bb19a850c0a249bede83bb6ed70
  runtime-dependency:
    registry: mcr.microsoft.com
    repository: windows/servercore
    tag: ltsc2019
    digest: sha256:2bacc4bdc5d1bd805587cb90a2fb2d58d1c775b02df1a19fd221cbfc639ff587
  git: {}


Run ID: cf1bun was successful after 5m1s
```