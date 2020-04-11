### Prerequisites: import base images
```sh
az acr import --force -n myregistry \
        --source mcr.microsoft.com/dotnet/core/aspnet:3.1-buster-slim \
        -t dotnet/core/aspnet:3.1-buster-slim

az acr import --force -n myregistry \
        --source mcr.microsoft.com/dotnet/core/sdk:3.1-buster \
        -t dotnet/core/sdk:3.1-buster
```

### Build Solution I: single-step
```sh
cd WeatherService

az acr build -r myregistry \
    -f Dockerfile \
    -t "weatherservice:{{.Run.ID}}" \
    --build-arg BaseImage="{{.Run.Registry}}/dotnet/core/aspnet:3.1-buster-slim" \
    --build-arg BuildImage="{{.Run.Registry}}/dotnet/core/sdk:3.1-buster" .
```
### Build Solution II: multi-steps

```sh
cd WeatherService

az acr run -r myregistry \
    -f acb.yaml .
```