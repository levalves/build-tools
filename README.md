# DevOps Build Tools

This repo holds the build scripts used by several Levalves projects.

- Current version of this lib: [v3](https://github.com/levalves/build-tools/tree/v3)


For older versions, read de docs:

- [v0](https://github.com/levalves/build-tools/blob/v0/README.md)
- [v1](https://github.com/levalves/build-tools/blob/v1/README.md)
- [v2](https://github.com/levalves/build-tools/blob/v2/README.md)

## Usage

### Clone the build tools repo

On your main script, clone some **major** version of this repo and import the desired libraries:

```
#!/usr/bin/env bash
set +x

if [ ! -d "$PWD/build-tools" ]; then
  git clone --single-branch --branch v3 git@github.com:levalves/build-tools.git "$PWD/build-tools"
fi

__BUILD_TOOLS_PATH="./build-tools"

source "$__BUILD_TOOLS_PATH/scripts/log.sh"
source "$__BUILD_TOOLS_PATH/scripts/k8s.sh"
source "$__BUILD_TOOLS_PATH/scripts/terraform.sh"
source "$__BUILD_TOOLS_PATH/scripts/docker.sh"
source "$__BUILD_TOOLS_PATH/scripts/secrets.sh"
source "$__BUILD_TOOLS_PATH/scripts/packer.sh"
source "$__BUILD_TOOLS_PATH/scripts/shell_overrides.sh"
source "$__BUILD_TOOLS_PATH/scripts/init_template.sh"
source "$__BUILD_TOOLS_PATH/scripts/s3_artifacts.sh"
source "$__BUILD_TOOLS_PATH/scripts/datadog_secret.sh"
source "$__BUILD_TOOLS_PATH/scripts/aws_credentials.sh"
```

## Available libraries

### Terraform

Read the docs [here](./docs/terraform.md).

### Packer

Read the docs [here](./docs/packer.md).

### Docker

Read the docs [here](./docs/docker.md).

### Secrets

Read the docs [here](./docs/secrets.md).

### Shell Overrides

Read the docs [here](./docs/shell_overrides.md).

### Init Template

Read the docs [here](./docs/init_template.md)

### S3 Artifacts

Read the docs [here](./docs/s3_artifacts.md)

### Retrieve Datadog Secret

Read the docs [here](./docs/datadog_secret.md)

### Set AWS credentials in a multi-account deployment scenario

Read the docs [here](./docs/aws_credentials.md)

### Kubernetes

Read the docs [here](./docs/k8s.md)

### Contributing

[How to Contribute:](CONTRIBUTING.md)
