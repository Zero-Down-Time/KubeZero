# ci-tools-lib

Various toolchain bits and pieces shared between projects

# Quickstart
Create top-level Makefile
```
REGISTRY := <your-registry>
IMAGE := <image_name>
REGION := <AWS region of your registry>

include .ci/podman.mk
```

Add subtree to your project:
```
git subtree add --prefix .ci https://git.zero-downtime.net/ZeroDownTime/ci-tools-lib.git main --squash
```


## Jenkins
Shared groovy libraries

## Make
Common Makefile include
