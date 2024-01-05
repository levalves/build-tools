set -eo pipefail

source "$__BUILD_TOOLS_PATH/scripts/log.sh"
source "$__BUILD_TOOLS_PATH/scripts/aws_credentials.sh"

update_kubeconfig() {
  __CLUSTER_NAME=$1
  __REGION=$2
  __AWS_ROLE_ARN=$3

  export KUBECONFIG="$PWD/.kube/config"
  set_aws_credentials $__AWS_ROLE_ARN

  f_log "Updating kubeconfig..."
  aws eks update-kubeconfig --region $__REGION --name $__CLUSTER_NAME --kubeconfig $KUBECONFIG
  chmod 600 $KUBECONFIG
}

kubectl_apply() {
  __CLUSTER_NAME=$1
  __REGION=$2
  __AWS_ROLE_ARN=$3
  __NAMESPACE=$4
  __K8S_WORKING_DIR=$5

  update_kubeconfig $__CLUSTER_NAME $__REGION $__AWS_ROLE_ARN

  f_log "Applying kubernetes files..."
  kubectl apply -n $__NAMESPACE -f $__K8S_WORKING_DIR

  reset_aws_credentials
}
