# Task with Managed Identities


## Access to Azure KeyVault and `az login` using Managed Identity

Task Definition file (managed-identities.yaml)

`managed-identities.yaml`
``` yaml
version: v1.0.0
secrets:
  - id: name
    keyvault: https://myvault.vault.azure.net/secrets/SampleSecret
steps:
  - cmd: bash -c 'if [ -z "$MY_SECRET" ]; then echo "Secret not resolved"; else echo "Secret resolved!!"; fi'
    env: 
      - MY_SECRET='{{.Secrets.name}}' 

  # Build/Push the website to source registry
  - cmd: docker build -t {{.Run.Registry}}/my-website:{{.Run.ID}} https://github.com/Azure-Samples/aci-helloworld.git
  - push: 
    - "{{.Run.Registry}}/my-website:{{.Run.ID}}"
  
  # Login to Azure and list the tags to verify if we have the Image!
  - cmd: microsoft/azure-cli az login --identity
  - cmd: microsoft/azure-cli az acr repository show-tags -n {{.Values.registryName}} --repository my-website
```

In this example, we will work with User defined Identities.

``` sh
// Create user assigned identity
az identity create -g $rg -n msi_user_identity
// capture principal_id, client_id and id from the response

// Add role assignment to Resource group
az role assignment create --role reader -g $rg --assignee $principal_id

Give access to KeyVault
az keyvault set-policy -n myvault --object-id $principal_id -g $rg --secret-permissions get

// Create Task 
az acr task create -n msitask -r $reg -c https://github.com/Azure-Samples/acr-tasks.git \
  -f managed-identities.yaml --pull-request-trigger-enabled false --commit-trigger-enabled false \
  --assign-identity $id
{
  "agentConfiguration": {
    "cpu": 2
  },
  "creationDate": "2019-05-16T21:38:14.935732+00:00",
  "credentials": null,
  "id": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/samashahtest-rg/providers/Microsoft.ContainerRegistry/registries/myregistry/tasks/msitask",
  "identity": {
    "principalId": null,
    "tenantId": null,
    "type": "UserAssigned",
    "userAssignedIdentities": {
      "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourcegroups/samashahtest-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/msi_user_identity": {
        "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
        "principalId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
      }
    }
  },
  "location": "westus",
  "name": "msitask",
  "platform": {
    "architecture": "amd64",
    "os": "linux",
    "variant": null
  },
  "provisioningState": "Succeeded",
  "resourceGroup": "samashahtest-rg",
  "status": "Enabled",
  "step": {
    "baseImageDependencies": null,
    "contextAccessToken": null,
    "contextPath": "https://github.com/Azure-Samples/acr-tasks.git#:ManagedIdentities",
    "taskFilePath": "acb.yaml",
    "type": "FileTask",
    "values": [],
    "valuesFilePath": null
  },
  "tags": null,
  "timeout": 3600,
  "trigger": {
    "baseImageTrigger": {
      "baseImageTriggerType": "Runtime",
      "name": "defaultBaseimageTriggerName",
      "status": "Enabled"
    },
    "sourceTriggers": null,
    "timerTriggers": null
  },
  "type": "Microsoft.ContainerRegistry/registries/tasks"
}

// Run Task
az acr task run -n msitask -r $reg --set registryName=$reg

Queued a run with ID: cfs
Waiting for an agent...
2019/05/24 00:09:32 Downloading source code...
2019/05/24 00:09:34 Finished downloading source code
2019/05/24 00:09:35 Using acb_vol_d7fc66dc-7ad4-473c-916a-16c8c074afa3 as the home volume
2019/05/24 00:09:37 Creating Docker network: acb_default_network, driver: 'bridge'
2019/05/24 00:09:38 Successfully set up Docker network: acb_default_network
2019/05/24 00:09:38 Setting up Docker configuration...
2019/05/24 00:09:39 Successfully set up Docker configuration
2019/05/24 00:09:39 Logging in to registry: samashahtesting.azurecr.io
2019/05/24 00:09:39 Successfully logged into samashahtesting.azurecr.io
2019/05/24 00:09:39 Executing step ID: acb_step_0. Working directory: '', Network: 'acb_default_network'
2019/05/24 00:09:39 Launching container with name: acb_step_0
Secret resolved!!
2019/05/24 00:09:41 Successfully executed container: acb_step_0
2019/05/16 21:53:33 Executing step ID: acb_step_1. Working directory: 'ManagedIdentities', Network: 'acb_default_network'
2019/05/16 21:53:33 Launching container with name: acb_step_1
Sending build context to Docker daemon  74.75kB
Step 1/6 : FROM node:8.9.3-alpine
8.9.3-alpine: Pulling from library/node
1160f4abea84: Pulling fs layer
66ff3f133e43: Pulling fs layer
4c8ff6f0a4db: Pulling fs layer
4c8ff6f0a4db: Verifying Checksum
4c8ff6f0a4db: Download complete
1160f4abea84: Verifying Checksum
1160f4abea84: Download complete
66ff3f133e43: Verifying Checksum
66ff3f133e43: Download complete
1160f4abea84: Pull complete
66ff3f133e43: Pull complete
4c8ff6f0a4db: Pull complete
Digest: sha256:40201c973cf40708f06205b22067f952dd46a29cecb7a74b873ce303ad0d11a5
Status: Downloaded newer image for node:8.9.3-alpine
---> 144aaf4b1367
Step 2/6 : RUN mkdir -p /usr/src/app
---> Running in a3ceb0ee6186
Removing intermediate container a3ceb0ee6186
---> b41128c4d968
Step 3/6 : COPY ./app/* /usr/src/app/
---> dd76285325ae
Step 4/6 : WORKDIR /usr/src/app
---> Running in 549f7d240dd0
Removing intermediate container 549f7d240dd0
---> 10e10771ccef
Step 5/6 : RUN npm install
---> Running in 5bb1dc4d2f29
npm notice created a lockfile as package-lock.json. You should commit this file.
npm WARN aci-helloworld@1.0.0 No description
npm WARN aci-helloworld@1.0.0 No repository field.
npm WARN aci-helloworld@1.0.0 No license field.
 
added 51 packages in 1.722s
Removing intermediate container 5bb1dc4d2f29
---> f2453882fadf
Step 6/6 : CMD node /usr/src/app/index.js
---> Running in b73f806e167f
Removing intermediate container b73f806e167f
---> 03cbf99fb99d
Successfully built 03cbf99fb99d
Successfully tagged myregistry.azurecr.io/my-website:cf3
2019/05/16 21:53:47 Successfully executed container: acb_step_1
2019/05/16 21:53:47 Executing step ID: acb_step_2. Working directory: 'ManagedIdentities', Network: 'acb_default_network'
2019/05/16 21:53:47 Pushing image: myregistry.azurecr.io/my-website:cf3, attempt 1
The push refers to repository [myregistry.azurecr.io/my-website]
94c3992a02ae: Preparing
5ac11183120f: Preparing
9abb510f612b: Preparing
1dfbdf308b77: Preparing
2ec940494cc0: Preparing
6dfaec39e726: Preparing
6dfaec39e726: Waiting
1dfbdf308b77: Layer already exists
2ec940494cc0: Layer already exists
6dfaec39e726: Layer already exists
5ac11183120f: Pushed
94c3992a02ae: Pushed
9abb510f612b: Pushed
cf3: digest: sha256:16e796bb40d2b0f78102a3d17f69444db10a6862ef40a771fd069f7cab8652a3 size: 1577
2019/05/16 21:53:54 Successfully pushed image: myregistry.azurecr.io/my-website:cf3
2019/05/16 21:53:54 Executing step ID: acb_step_3. Working directory: 'ManagedIdentities', Network: 'acb_default_network'
2019/05/16 21:53:54 Launching container with name: acb_step_3
[
  {
    "environmentName": "AzureCloud",
    "id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "isDefault": true,
    "name": "ACR - TEST",
    "state": "Enabled",
    "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "user": {
      "assignedIdentityInfo": "MSI",
      "name": "systemAssignedIdentity",
      "type": "servicePrincipal"
    }
  }
]
2019/05/16 21:53:58 Successfully executed container: acb_step_3
2019/05/16 21:53:58 Executing step ID: acb_step_4. Working directory: 'ManagedIdentities', Network: 'acb_default_network'
2019/05/16 21:53:58 Launching container with name: acb_step_4
[
  "cf2",
  "cf3"
]
2019/05/16 21:54:02 Successfully executed container: acb_step_4
2019/05/16 21:54:02 Step ID: acb_step_0 marked as successful (elapsed time in seconds: 1.070111)
2019/05/16 21:54:02 Step ID: acb_step_1 marked as successful (elapsed time in seconds: 14.031206)
2019/05/16 21:54:02 Step ID: acb_step_2 marked as successful (elapsed time in seconds: 7.053921)
2019/05/16 21:54:02 Step ID: acb_step_3 marked as successful (elapsed time in seconds: 3.741742)
2019/05/16 21:54:02 Step ID: acb_step_4 marked as successful (elapsed time in seconds: 4.274584)
 
Run ID: cf3 was successful after 38s
```

## Private registry login using Managed Identities


We will use System Identity for this example.

Task:

`testtask.yaml`
``` yaml
version: v1.0.0
steps:
  - build: -t {{.Values.REGISTRY1}}/hello-world:{{.Run.ID}} . -f hello-world.dockerfile
  - push: ["{{.Values.REGISTRY1}}/hello-world:{{.Run.ID}}"]
  - build: -t {{.Values.REGISTRY2}}/hello-world:{{.Run.ID}} . -f hello-world.dockerfile
  - push: ["{{.Values.REGISTRY2}}/hello-world:{{.Run.ID}}"]
```


``` sh
az acr task create -n multiple-reg -r $reg -c https://github.com/Azure-Samples/acr-tasks.git#:multipleRegistries \
   -f testtask.yaml --commit-trigger-enabled false --pull-request-trigger-enabled false \
   --assign-identity

{
  "agentConfiguration": {
    "cpu": 2
  },
  "creationDate": "2019-05-16T22:54:04.620200+00:00",
  "credentials": null,
  "id": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/samashahtest-rg/providers/Microsoft.ContainerRegistry/registries/myregistry/tasks/multiple-reg",
  "identity": {
    "principalId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "type": "SystemAssigned",
    "userAssignedIdentities": null
  },
  "location": "westus",
  "name": "multiple-reg",
  "platform": {
    "architecture": "amd64",
    "os": "linux",
    "variant": null
  },
  "provisioningState": "Succeeded",
  "resourceGroup": "samashahtest-rg",
  "status": "Enabled",
  "step": {
    "baseImageDependencies": null,
    "contextAccessToken": null,
    "contextPath": "https://github.com/Azure-Samples/acr-tasks.git#:multipleRegistries",
    "taskFilePath": "testtask.yaml",
    "type": "FileTask",
    "values": [],
    "valuesFilePath": null
  },
  "tags": null,
  "timeout": 3600,
  "trigger": {
    "baseImageTrigger": {
      "baseImageTriggerType": "Runtime",
      "name": "defaultBaseimageTriggerName",
      "status": "Enabled"
    },
    "sourceTriggers": null,
    "timerTriggers": null
  },
  "type": "Microsoft.ContainerRegistry/registries/tasks"
}

// Capture id and principal_id from response.

az role assignment create --assignee $principal_id \
  --scope '/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/$rg/providers/Microsoft.ContainerRegistry/registries/customregistry1' \
  --role acrpush

az role assignment create --assignee $principal_id \
  --scope '/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/$rg/providers/Microsoft.ContainerRegistry/registries/customregistry2' \
  --role acrpush

az acr task credential add -n multiple-reg -r $reg \
  --login-server customregistry1.azurecr.io \
  --use-identity [system]
{
  "customregistry1.azurecr.io": null
}

az acr task credential add -n multiple-reg -r myregistry \
  --login-server customregistry2.azurecr.io \
  --use-identity [system]
{
  "customregistry1.azurecr.io": null,
  "customregistry2.azurecr.io": null
}

az acr task run -n multiple-reg -r $reg \
  --set REGISTRY1=customregistry1.azurecr.io \
  --set REGISTRY2=customregistry2.azurecr.io
Queued a run with ID: cf7
Waiting for an agent...
2019/05/16 23:09:25 Downloading source code...
2019/05/16 23:09:27 Finished downloading source code
2019/05/16 23:09:27 Using acb_vol_710b28ac-0b48-45f1-a16b-e54c46484be6 as the home volume
2019/05/16 23:09:30 Creating Docker network: acb_default_network, driver: 'bridge'
2019/05/16 23:09:30 Successfully set up Docker network: acb_default_network
2019/05/16 23:09:30 Setting up Docker configuration...
2019/05/16 23:09:31 Successfully set up Docker configuration
2019/05/16 23:09:31 Logging in to registry: customregistry2.azurecr.io
2019/05/16 23:09:32 Successfully logged into customregistry2.azurecr.io
2019/05/16 23:09:32 Logging in to registry: myregistry.azurecr.io
2019/05/16 23:09:33 Successfully logged into myregistry.azurecr.io
2019/05/16 23:09:33 Logging in to registry: customregistry1.azurecr.io
2019/05/16 23:09:34 Successfully logged into customregistry1.azurecr.io
2019/05/16 23:09:34 Executing step ID: acb_step_0. Working directory: 'multipleRegistries', Network: 'acb_default_network'
2019/05/16 23:09:34 Scanning for dependencies...
2019/05/16 23:09:35 Successfully scanned dependencies
2019/05/16 23:09:35 Launching container with name: acb_step_0
Sending build context to Docker daemon  4.096kB
Step 1/1 : FROM hello-world
---> fce289e99eb9
Successfully built fce289e99eb9
Successfully tagged customregistry1.azurecr.io/hello-world:cf7
2019/05/16 23:09:36 Successfully executed container: acb_step_0
2019/05/16 23:09:36 Executing step ID: acb_step_1. Working directory: 'multipleRegistries', Network: 'acb_default_network'
2019/05/16 23:09:36 Pushing image: customregistry1.azurecr.io/hello-world:cf7, attempt 1
The push refers to repository [customregistry1.azurecr.io/hello-world]
af0b15c8625b: Preparing
af0b15c8625b: Pushed
cf7: digest: sha256:92c7f9c92844bbbb5d0a101b22f7c2a7949e40f8ea90c8b3bc396879d95e899a size: 524
2019/05/16 23:09:38 Successfully pushed image: customregistry1.azurecr.io/hello-world:cf7
2019/05/16 23:09:38 Executing step ID: acb_step_2. Working directory: 'multipleRegistries', Network: 'acb_default_network'
2019/05/16 23:09:38 Scanning for dependencies...
2019/05/16 23:09:39 Successfully scanned dependencies
2019/05/16 23:09:39 Launching container with name: acb_step_2
Sending build context to Docker daemon  4.096kB
Step 1/1 : FROM hello-world
---> fce289e99eb9
Successfully built fce289e99eb9
Successfully tagged customregistry2.azurecr.io/hello-world:cf7
2019/05/16 23:09:40 Successfully executed container: acb_step_2
2019/05/16 23:09:40 Executing step ID: acb_step_3. Working directory: 'multipleRegistries', Network: 'acb_default_network'
2019/05/16 23:09:40 Pushing image: customregistry2.azurecr.io/hello-world:cf7, attempt 1
The push refers to repository [customregistry2.azurecr.io/hello-world]
af0b15c8625b: Preparing
af0b15c8625b: Pushed
cf7: digest: sha256:92c7f9c92844bbbb5d0a101b22f7c2a7949e40f8ea90c8b3bc396879d95e899a size: 524
2019/05/16 23:09:52 Successfully pushed image: customregistry2.azurecr.io/hello-world:cf7
2019/05/16 23:09:52 Step ID: acb_step_0 marked as successful (elapsed time in seconds: 2.028433)
2019/05/16 23:09:52 Populating digests for step ID: acb_step_0...
2019/05/16 23:09:54 Successfully populated digests for step ID: acb_step_0
2019/05/16 23:09:54 Step ID: acb_step_1 marked as successful (elapsed time in seconds: 1.937504)
2019/05/16 23:09:54 Step ID: acb_step_2 marked as successful (elapsed time in seconds: 2.012841)
2019/05/16 23:09:54 Populating digests for step ID: acb_step_2...
2019/05/16 23:09:56 Successfully populated digests for step ID: acb_step_2
2019/05/16 23:09:56 Step ID: acb_step_3 marked as successful (elapsed time in seconds: 12.556689)
2019/05/16 23:09:56 The following dependencies were found:
2019/05/16 23:09:56 
- image:
    registry: customregistry1.azurecr.io
    repository: hello-world
    tag: cf7
    digest: sha256:92c7f9c92844bbbb5d0a101b22f7c2a7949e40f8ea90c8b3bc396879d95e899a
  runtime-dependency:
    registry: registry.hub.docker.com
    repository: library/hello-world
    tag: latest
    digest: sha256:92695bc579f31df7a63da6922075d0666e565ceccad16b59c3374d2cf4e8e50e
  git:
    git-head-revision: b0ffa6043dd893a4c75644c5fed384c82ebb5f9e
- image:
    registry: customregistry2.azurecr.io
    repository: hello-world
    tag: cf7
    digest: sha256:92c7f9c92844bbbb5d0a101b22f7c2a7949e40f8ea90c8b3bc396879d95e899a
  runtime-dependency:
    registry: registry.hub.docker.com
    repository: library/hello-world
    tag: latest
    digest: sha256:92695bc579f31df7a63da6922075d0666e565ceccad16b59c3374d2cf4e8e50e
  git:
    git-head-revision: b0ffa6043dd893a4c75644c5fed384c82ebb5f9e
 
 
Run ID: cf7 was successful after 32s
```

## Private registry login using Azure keyvault

Same task and steps can be used as in the above example. 

The only difference here would be adding a Keyvault credential to the task instead of identity. 

For instance, say, you want to use MSI to fetch your username/password from keyvault, you can do this:

```
// Give MSI access to your keyvault to fetch secrets from:
az keyvault set-policy -n mykeyvault --object-id $principal_id -g $rg \
  --secret-permissions get

// Link your credentials to your task
// Note how you can also add plaintext credentials
az acr task credential add -n multiple-reg -r $reg \
  --login-server customregistry1.azurecr.io \
   -u 'myusername' \
   -p 'https://mykeyvault.vault.azure.net/secrets/secretpassword' \
   --use-identity [system]
{
  "customregistry1.azurecr.io": null
}

az acr task credential add -n multiple-reg -r myregistry 
    --login-server customregistry2.azurecr.io \
    -u 'https://mykeyvault.vault.azure.net/secrets/secretusername' \
    -p 'https://mykeyvault.vault.azure.net/secrets/secretpassword' \
    --use-identity [system]
{
  "customregistry1.azurecr.io": null,
  "customregistry2.azurecr.io": null
}
```