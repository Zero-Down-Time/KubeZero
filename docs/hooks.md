# KubeZero Helm hooks

## Abstract
Scripts within the `hooks.d` folder of each chart are executed at the respective times when the charts are applied via libhelm.

*These hooks do NOT work via ArgoCD*

## Flow
- hooks are execute as part of the libhelm tasks like `apply`
- are running with the current kubectl context
- executed at root working directory, eg. set a value for helm the scripts can edit the `./values.yaml` file.
