set -eo pipefail
source "$__BUILD_TOOLS_PATH/scripts/secrets.sh"

get_dd_secret() {
  __ENV=$1
  __REGION=$2
  __AWS_ROLE_ARN=$3

  set_aws_credentials $__AWS_ROLE_ARN
  _DATADOG_SECRET_ARN=$(aws secretsmanager describe-secret --secret-id datadog-secret-$__ENV --region $__REGION --query 'ARN' | sed s/\"//g)
  reset_aws_credentials

  get_secrets_manager_value $_DATADOG_SECRET_ARN $__REGION "AWSCURRENT" $__AWS_ROLE_ARN
  ___DD_API_KEY=$(echo $___SECRET_VALUE | jq --raw-output '.DD_API_KEY')
  ___DD_AGENT_VERSION=$(echo $___SECRET_VALUE | jq --raw-output '.DD_AGENT_VERSION')

}
