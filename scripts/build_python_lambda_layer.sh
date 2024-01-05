set -eo pipefail

source "$__BUILD_TOOLS_PATH/scripts/log.sh"

build_python_lambda_layer() {
  __PYTHON_VERSION=$1
  __REQUIREMENTS_FILE_PATH=$2
  __INSTALL_DIR=$3

  f_log "python version: $__PYTHON_VERSION"
  f_log "requirements file: $__REQUIREMENTS_FILE_PATH"
  f_log "install dir: $__INSTALL_DIR"

  __CONTAINER_NAME="c-$(date +%Y%m%d%H%M%S)"

  cp $__REQUIREMENTS_FILE_PATH $__BUILD_TOOLS_PATH/scripts/python_layer_build/requirements.txt
  docker build --force-rm --build-arg python_version="$__PYTHON_VERSION" -t python-requirements $__BUILD_TOOLS_PATH/scripts/python_layer_build
  docker create -ti --name $__CONTAINER_NAME python-requirements bash

  mkdir -p $__INSTALL_DIR
  docker cp $__CONTAINER_NAME:/python $__INSTALL_DIR
  docker rm -f $__CONTAINER_NAME
  docker rmi python-requirements
}
