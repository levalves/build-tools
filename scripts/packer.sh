set -eo pipefail

source "$__BUILD_TOOLS_PATH/scripts/log.sh"

get_ami_by_name() {
  __REGION=$1
  __AMI_NAME=$2
  __AWS_ROLE_ARN=$3

  set_aws_credentials $__AWS_ROLE_ARN
  _AMI_ID=$(AWS_DEFAULT_REGION=$__REGION aws ec2 describe-images --filters Name=name,Values=$__AMI_NAME --output json | jq --raw-output '.Images[0].ImageId')
  reset_aws_credentials
}

build_ami() {
  __REGION=$1
  __AMI_NAME=$2
  __ANSIBLE_GALAXY_REQ_PATH=$3
  __VARIABLES_FILE=$4
  __TEMPLATE_FILE=$5
  __AWS_ROLE_ARN=$6

  get_ami_by_name $__REGION $__AMI_NAME $__AWS_ROLE_ARN

  if [ "$_AMI_ID" != "null" ]; then
    f_log "AMI $__AMI_NAME already exists: $_AMI_ID"
  else
    f_log "Starting packer build..."

    ansible-galaxy install -r $__ANSIBLE_GALAXY_REQ_PATH

    export PACKER_LOG=1
    export PACKER_LOG_PATH=packer.log

    set_aws_credentials $__AWS_ROLE_ARN
    packer build \
      -color=false \
      -var-file="$__VARIABLES_FILE" \
      $__TEMPLATE_FILE
  # Restore credentials
    reset_aws_credentials
    get_ami_by_name $__REGION $__AMI_NAME $__AWS_ROLE_ARN
    f_log "AMI successfully built: $_AMI_ID"
  fi
}
