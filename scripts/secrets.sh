set -eo pipefail

source "$__BUILD_TOOLS_PATH/scripts/log.sh"
source "$__BUILD_TOOLS_PATH/scripts/aws_credentials.sh"

get_secrets_manager_value() {
  unset __VERSION_STAGE
  __SECRET_ID=$1
  __REGION=$2
  __VERSION_STAGE=${3:-"AWSCURRENT"}
  __AWS_ROLE_ARN=$4

  unset ___SECRET_VALUE
  if [[ -z $__SECRET_ID || -z $__REGION || -z $__VERSION_STAGE ]]
  then
    echo "One or more required parameters are empty: SECRET_ID, REGION or VERSION_STAGE"
    exit 1
  else
    set_aws_credentials $__AWS_ROLE_ARN
    _RESULT=$(AWS_DEFAULT_REGION=$__REGION aws secretsmanager get-secret-value --secret-id "${__SECRET_ID}" --version-stage $__VERSION_STAGE --output json)
    ___SECRET_VALUE=$(echo $_RESULT | jq --raw-output '.SecretString')
    reset_aws_credentials
    f_log "Secret $__SECRET_ID retrieved successfully"
  fi
}
