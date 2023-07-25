# enso templates

# 1. introduction
these are a set of repository templates i setup for a few different languages

- https://github.com/loeken/enso-template-base
- https://github.com/loeken/enso-template-go
- https://github.com/loeken/enso-template-python
- https://github.com/loeken/enso-template-nodejs

all these repos ship with a similar setup:


# 2. setup
## 2.1. create .env file
this file is for local development, when running in prod modes the secrets will be injected as env vars, your app shall read from env vars. the .env file should be kept only on your local system and have different values for passwords compared to your production environment.
```
cp .env.example .env
```

## 2.2. open in vscode as devcontainer
- open project in vscode
- you should see a project to build and open as devcontainer

# 3. components/folders
## 3.1. .devcontainer folder
this folder contains a json defining how vscode can start the contents of this folder. It defines which extensions to install in vscode, and runs the docker-compose.ymal file which in turn will startup the app defined in deploy/docker/Dockerfile.dev

on first load of the project you will be asked to:
```
Folder contains a Dev Container configuration file. Reopen folder to develop in a container
```

click on the "Reopen in Container", ( read more in [2. setup](#2-setup))

This will start the application via docker-compose and also allows you to start the container as a codespace on github's infrastructure and allows you to scale up the hardware.

## 3.2. .github folder
the go/python/nodejs repos use the enso-template-base as an upstream, the github folder contains a workflow to publish the enso-template-base* images on docker hub so they can be re-used in the other templates

## 3.3. .vscode folder
this has the launch config ( when pressing F5 in vscode's devcontainer/codespace, it will start the application, if supported in debug mode )

## 3.4. deploy folder
### 3.4.1. deploy/docker folder
this folder contains all the dockerfiles

### 3.4.2. deploy/helm folder
this contains the helm chart to startup this application

### 3.4.3. deploy/argocd folder
this contains argocd app definitions to install helm charts (mostly localted in deploy/helm )
