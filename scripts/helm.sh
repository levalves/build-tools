set -eo pipefail

source "$__BUILD_TOOLS_PATH/scripts/log.sh"
source "$__BUILD_TOOLS_PATH/scripts/shell_overrides.sh"
source "$__BUILD_TOOLS_PATH/scripts/aws_credentials.sh"
source "$__BUILD_TOOLS_PATH/scripts/k8s.sh"

helm_upgrade() {
  __CLUSTER_NAME=$1
  __REGION=$2
  __ENV=$3
  __AWS_ROLE_ARN=$4
  __APPNAME=$5
  __NAMESPACE=$6
  __VALUES_FILE=$7
  __IMAGE_NAME=$8
  __IMAGE_TAG=$9
  __HELM_WORKING_DIR=${10}
  __HELM_CHART_VERSION=${11:-"1.4.1"}
  __HELM_EXTRAS=${12}

  pushd $__HELM_WORKING_DIR

  update_kubeconfig $__CLUSTER_NAME $__REGION $__AWS_ROLE_ARN
  f_log "Add S3 plugin..."
  helm plugin install https://github.com/hypnoglow/helm-s3.git --version 0.12.0 || true

  f_log "Add levalves repo..."
  AWS_REGION=us-east-1 helm repo add levalves s3://levalves-helm-charts/levalves/app

  f_log "Upgrade/Install app..."
  AWS_REGION=us-east-1 helm upgrade -i \
    --atomic --cleanup-on-fail \
    --version=$__HELM_CHART_VERSION \
    -n $__NAMESPACE -f $__VALUES_FILE \
    --set nameOverride=$__APPNAME \
    --set fullnameOverride=$__APPNAME \
    --set environment=$__ENV \
    --set image.repository=$__IMAGE_NAME \
    --set image.tag=$__IMAGE_TAG \
    $__HELM_EXTRAS $__APPNAME levalves/app
  reset_aws_credentials

  popd
}
