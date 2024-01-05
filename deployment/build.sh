#!/bin/bash
set -eo pipefail
set +x

if [ ! -d "$PWD/build-tools" ]; then
  git clone --single-branch --branch v1 git@github.com-levalves:levalves/build-tools.git "$PWD/build-tools"
fi

__BUILD_TOOLS_PATH="./build-tools"

LOG_FILE="$PWD/build.log"
rm -f $LOG_FILE

source "$__BUILD_TOOLS_PATH/scripts/log.sh"
source "$__BUILD_TOOLS_PATH/scripts/terraform.sh"
source "$__BUILD_TOOLS_PATH/scripts/docker.sh"
source "$__BUILD_TOOLS_PATH/scripts/check-ecs-deployment.sh"
source "$__BUILD_TOOLS_PATH/scripts/shell_overrides.sh"
source "$__BUILD_TOOLS_PATH/scripts/secrets.sh"
source "$__BUILD_TOOLS_PATH/scripts/aws_credentials.sh"

COMMIT_HASH=${COMMIT_HASH:-$(git log --pretty=format:%h -n 1)}

# CHANGE REPO NAME HERE
REPO="pix-qrcode-$ENV"
SECRET_NAME="pix-qrcode"

f_log "COMMIT_HASH is set to $COMMIT_HASH"
export TF_VAR_commit_hash="$COMMIT_HASH"

f_create_ecr(){
  f_get_account_id
  f_get_region
  f_log "Creating $Repo..."
  f_get_role
  set_aws_credentials $ROLE
  REGION=$(f_get_region)
  ACCOUNT_ID=$(f_get_account_id)
  if aws ecr describe-repositories --repository-names "$REPO" >/dev/null 2>&1; then
    f_log "O repositório $REPO já existe."
  else
    if aws ecr create-repository --repository-name "$REPO" --image-scanning-configuration scanOnPush=true >/dev/null 2>&1; then
      f_log "O repositório $REPO foi criado com sucesso."
    else
      f_log "Falha ao criar o repositório $REPO."
    fi
  fi
}

f_delete_ecr(){
  f_get_account_id
  f_get_region
  f_log "Deleting $REPO..."
  f_get_role
  set_aws_credentials $ROLE
  REGION=$(f_get_region)
  ACCOUNT_ID=$(f_get_account_id)
  if aws ecr delete-repository --repository-name $REPO --force >/dev/null 2>&1; then
    f_log "O repositório $REPO foi apagado com sucesso."
  else
    if aws ecr describe-repositories --repository-names "$REPO" >/dev/null 2>&1; then
      f_log "O repositório $REPO nao existe."
    else
      f_log "Falha ao deletar o repositório $REPO."
    fi
  fi
}

f_terraform_init() {
  terraform_init $ENV "$PWD/terraform"
}

f_get_region(){
  REGION=$(find . -iname "$ENV.tfvars" | xargs -I {} cat {} | grep -e ^region | cut -d \= -f2 | sed 's/ "//g;s/"//g')
  echo $REGION
} 

f_get_role() {
  if [ "$ENV" == "production" ]; then
    ROLE="arn:aws:iam::327667905059:role/CrossAccount-Pagzoop_Prod"
  else
    ROLE="arn:aws:iam::327667905059:role/CrossAccount-Pagzoop_Prod"
  fi
  echo $ROLE
}

f_get_account_id(){
  ROLE=$(f_get_role)
  ACCOUNT_ID="$(echo $ROLE | cut -d \: -f5)"
  echo $ACCOUNT_ID
}

f_get_repo_name(){
  REGION=$(f_get_region)
  ACCOUNT_ID=$(f_get_account_id)
  REPO_NAME="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO"
  echo $REPO_NAME
}

f_build_testplan() {
  f_terraform_init
  f_get_role
  set_aws_credentials $ROLE
  terraform_testplan $ENV "$PWD/terraform" environments/$ENV.tfvars
}

  f_build_plan() {
    f_terraform_init
    f_get_role
    set_aws_credentials $ROLE
    export TF_VAR_build_version=$BUILD_NUMBER
    terraform_plan $ENV "$PWD/terraform" $COMMIT_HASH environments/$ENV.tfvars
  }

f_post_apply() {
  SERVICE_NAME=$(terraform output ecs_service_name | cut -d"\"" -f2)
  CLUSTER=$(terraform output cluster_name | cut -d"\"" -f2)
}

f_build_apply() {
  f_terraform_init
  f_get_role
  set_aws_credentials $ROLE
  terraform_apply $ENV "$PWD/terraform" $COMMIT_HASH f_post_apply
}

f_destroy_testplan() {
  terraform_destroy_testplan $ENV "$PWD/terraform" environments/$ENV.tfvars
}

f_destroy_plan() {
  terraform_destroy_plan $ENV "$PWD/terraform" $COMMIT_HASH environments/$ENV.tfvars
}

f_destroy_apply() {
  if [ "$ENV" == "production" ]; then
    f_log "INFO: It seems like you want to destroy a production environment. Please do it manually :-D"
    exit 1
  else
    terraform_destroy $ENV "$PWD/terraform" $COMMIT_HASH
    f_delete_ecr
  fi
}

f_get_secrets_manager_value() {
  REGION=$(f_get_region)
  get_secrets_manager_value "zp-$ENV-sm-$SECRET_NAME" $REGION
  DB_HOST=$(echo $___SECRET_VALUE | jq --raw-output '.DB_HOST')
  DB_NAME=$(echo $___SECRET_VALUE | jq --raw-output '.DB_NAME')
  DB_ADM_USER=$(echo $___SECRET_VALUE | jq --raw-output '.DB_ADM_USER')
  DB_ADM_PASS=$(echo $___SECRET_VALUE | jq --raw-output '.DB_ADM_PASS')
  SLACK_TOKEN=$(echo $___SECRET_VALUE | jq --raw-output '.SLACK_TOKEN')
}

f_get_secrets() {
	if [ "${ENV}" == "staging" ]; then
		get_dd_secret "banking-$ENV" $REGION
	else
		get_dd_secret $ENV $REGION
	fi

	export DD_API_KEY=$___DD_API_KEY
	export DD_AGENT_VERSION=$___DD_AGENT_VERSION
}

REPO_NAME=$(f_get_repo_name)
IMAGE_TAG="$REPO_NAME:$COMMIT_HASH"

 f_build_artifact() {
   f_setup_codeartifact_token
   echo "Building artifact in $(dirname $PWD)"
 }

f_docker_build_image() {
  f_create_ecr
  f_get_role
  set_aws_credentials $ROLE
  f_setup_codeartifact_token
  REGION=$(f_get_region)
  ACCOUNT_ID=$(f_get_account_id)
  echo "Building image version: $BUILD_NUMBER"
  build_image "$(dirname $PWD)/Dockerfile" $IMAGE_TAG $REGION "TOKEN=$CODEARTIFACT_AUTH_TOKEN"
  set_aws_credentials $ROLE
}

f_docker_push_image() {
  f_get_role
  set_aws_credentials $ROLE
  REGION=$(f_get_region)
  ROLE=$(f_get_role)
  push_image $IMAGE_TAG $REGION $ROLE
  set_aws_credentials $ROLE
}

f_check_deployment() {
  f_get_role
  set_aws_credentials $ROLE
  REGION=$(f_get_region)
  CLUSTER= echo $CLUSTER | sed 's/ "//g;s/"//g'
  SERVICE_NAME= echo $SERVICE_NAME | sed 's/ "//g;s/"//g'
  check_deployment $REGION $CLUSTER $SERVICE_NAME 2400
}

f_setup_codeartifact_token() {
  f_get_account_id
  f_get_region
  f_log "Setting Codeartifact token"
  f_get_role
  set_aws_credentials $ROLE
  export CODEARTIFACT_AUTH_TOKEN=$(aws codeartifact get-authorization-token \
    --region "us-east-1" \
    --domain pix-jd-sdk \
    --query authorizationToken \
    --output text \
    --duration-seconds 900)
}

case "$1" in
  build-artifact)
    f_build_artifact
  ;;
  
  build-docker-img)
    f_docker_build_image
    f_docker_push_image
  ;;

  testplan)
    f_build_testplan
  ;;

  plan)
    f_build_plan
  ;;

  apply)
    f_build_apply
  ;;

  deploy)
    f_build_plan
    f_build_apply
    f_check_deployment
  ;;

  destroy-testplan)
    f_destroy_testplan
  ;;

  destroy-plan)
    f_destroy_plan
  ;;

  destroy-apply)
    f_destroy_apply
  ;;

  get-secrets)
    f_get_secrets_manager_value
  ;;
  
  *)
    echo "usage: build.sh
    build-docker-img|testplan|plan|apply|deploy|destroy-testplan|destroy-plan|destroy-apply|get-secrets|build-artifact"
    exit 0
  ;;

esac
