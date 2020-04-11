### Use Single-Step Build
```sh
cd WeatherService
az acr build -f Dockerfile -r myregistry -t "weatherservice:{{.Run.ID}}" --build-arg BaseImage="{{.Run.Registry}}/dotnet/core/aspnet:3.1-buster-slim" --build-arg BuildImage="{{.Run.Registry}}/dotnet/core/sdk:3.1-buster" .
```
### Use Multi-Step Build

```sh
cd WeatherService
az acr run -f acb.yaml -r myregistry .
```