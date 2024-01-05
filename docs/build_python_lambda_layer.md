# Build Python Lambda Layer

This library helps building a Lambda Layer for Python runtimes.
It uses a docker image to build the layer, this way the built library is agnostic from the guest OS host to avoid compatibility issues.

Available methods:
- [build_python_lambda_layer](#build_python_lambda_layer)

<a name="build_python_lambda_layer"></a>

## build_python_lambda_layer

Builds a Lambda Layer for a Python runtime version.

### Requirements

Docker Container Runtime installed at build host.

### Inputs

|Name|Description|Default|Required|
|----|-----------|-------|--------|
|PYTHON_VERSION|Python runtime version used to build Lambda layer.|N/A|yes|
|REQUIREMENTS_FILE_PATH|Local path to the requirements file used to install python libraries.|N/A|yes|
|INSTALL_DIR|Where python libraries will be installed.|N/A|yes|

### Outputs

None.

### Example

```bash
f_build_layer() {
  rm -rf ../package
  PYTHON_VERSION=3.8
  REQUIREMENTS_FILE_PATH=../function/requirements.txt
  INSTALL_DIR=../package
  build_python_lambda_layer $PYTHON_VERSION $REQUIREMENTS_FILE_PATH $INSTALL_DIR
}
```
