set -eo pipefail

source "$__BUILD_TOOLS_PATH/scripts/log.sh"

set_aws_credentials(){
  __AWS_ROLE_ARN=$1
  __AUTOMATION_USER=${2:-azdevops}
  __APP_NAME=${3:-"$__AUTOMATION_USER"}
  __COMMIT_HASH=${4:-"$(date +%Y-%m-%d-%H-%M-%S)"}

  _AUTOMATION_USER=$(whoami)

  if [ "$_AUTOMATION_USER" == "${__AUTOMATION_USER}" ]; then
    unset AWS_SECRET_ACCESS_KEY
    unset AWS_SESSION_TOKEN
    unset AWS_ACCESS_KEY_ID
  else
    export _ASAK=$AWS_SECRET_ACCESS_KEY
    export _AST=$AWS_SESSION_TOKEN
    export _AAKI=$AWS_ACCESS_KEY_ID
  fi

  _TEMP=$(mktemp)
  aws sts assume-role --role-arn $__AWS_ROLE_ARN --role-session-name $__APP_NAME-$__COMMIT_HASH --output json > $_TEMP

  AWS_ACCESS_KEY_ID=$(cat $_TEMP | jq -r '.Credentials.AccessKeyId')
  AWS_SECRET_ACCESS_KEY=$(cat $_TEMP | jq -r '.Credentials.SecretAccessKey')
  AWS_SESSION_TOKEN=$(cat $_TEMP | jq -r '.Credentials.SessionToken')

  export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"
  export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"
  export AWS_SESSION_TOKEN="$AWS_SESSION_TOKEN"
}

reset_aws_credentials(){
  __AUTOMATION_USER=${1:-azdevops}

  if [ "$_AUTOMATION_USER" != "${__AUTOMATION_USER}" ]; then
    export AWS_SECRET_ACCESS_KEY=$_ASAK
    export AWS_SESSION_TOKEN=$_AST
    export AWS_ACCESS_KEY_ID=$_AAKI
    unset _ASAK
    unset _AST
    unset _AAKI
  else
    unset AWS_SECRET_ACCESS_KEY
    unset AWS_SESSION_TOKEN
    unset AWS_ACCESS_KEY_ID
  fi
}
