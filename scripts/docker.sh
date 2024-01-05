set -eo pipefail

source "$__BUILD_TOOLS_PATH/scripts/log.sh"
source "$__BUILD_TOOLS_PATH/scripts/aws_credentials.sh"

build_image() {
  __DOCKER_FILE_PATH=$1
  __TAG=$2
  __REGION=$3
  __ARG=$4

  export DOCKER_BUILD=1
  docker build -f $__DOCKER_FILE_PATH -t $__TAG $(dirname $__DOCKER_FILE_PATH) $(
    if [ -n "$__ARG" ]; then
        for i in $__ARG; do
            echo "--build-arg "$i"";
        done
    fi
  )

  f_log "Image $__TAG was built successfully"
}

push_image() {
  __TAG=$1
  __REGION=$2
  __AWS_ROLE_ARN=$3

  export ACCOUNT_ID="$(echo $__AWS_ROLE_ARN | cut -d \: -f5)"
  set_aws_credentials $__AWS_ROLE_ARN
  aws ecr get-login-password --region $__REGION | docker login --username AWS --password-stdin "$ACCOUNT_ID.dkr.ecr.$__REGION.amazonaws.com"
  docker push $__TAG
  reset_aws_credentials

  f_log "Successfully pushed image $__TAG" 
}
