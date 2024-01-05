set -eo pipefail

source "$__BUILD_TOOLS_PATH/scripts/log.sh"
source "$__BUILD_TOOLS_PATH/scripts/aws_credentials.sh"
export TF_IN_AUTOMATION=1

build_var_file_args() {

  __START_POSITION=$1

  VAR_FILES=""
  for i in $(seq $__START_POSITION $#)
  do
    eval TFVARS_FILE_PATH='$'$i
    VAR_FILES="$VAR_FILES -var-file=$__TF_WORKING_DIR/$TFVARS_FILE_PATH"
  done

}

terraform_init() {
  __WORKSPACE=$1
  __TF_WORKING_DIR=$2
  __BACKEND_CONFIG_PATH=${3:-}

  if [ -z "$__WORKSPACE" ]; then
    f_log "ERROR: __WORKSPACE param is required"
    exit 1
  fi

  if [ -z "$__TF_WORKING_DIR" ]; then
    f_log "ERROR: __TF_WORKING_DIR param is required"
    exit 1
  fi
  pushd $__TF_WORKING_DIR

  if [ -f .terraform_init.lock ]; then
    if [[ $(cat .terraform_init.lock) == "$__WORKSPACE" ]]; then
      f_log "Terraform already initialized!"
    else
      f_log "ERROR: Terraform already initialized for another workspace."
      exit 1
    fi
  else
    f_log "Trying to initialize Terraform..."

    if [ -z "$__BACKEND_CONFIG_PATH" ]; then
      terraform init -no-color
    else
      terraform init -backend-config="$__BACKEND_CONFIG_PATH" -no-color
    fi
    
    set +e
    terraform workspace select -no-color $__WORKSPACE

    if [ $? -eq 0 ]; then
      f_log "Workspace $__WORKSPACE selected"
    else
      terraform workspace new -no-color $__WORKSPACE
      f_log "Workspace $__WORKSPACE created"
    fi
    set -e

    echo "$__WORKSPACE" > .terraform_init.lock
    f_log "Terraform successfully initialized!"
  fi

  popd
}

terraform_plan() {
  __WORKSPACE=$1
  __TF_WORKING_DIR=$2
  __COMMIT_HASH=$3

  terraform_init $__WORKSPACE $__TF_WORKING_DIR

  pushd $__TF_WORKING_DIR

  TFPLAN="tfplan-$__WORKSPACE-$__COMMIT_HASH"
  rm -rf $TFPLAN

  build_var_file_args 5 $@

  f_log "Creating Terraform plan file..."
  terraform plan -no-color  -input=false $VAR_FILES -out="$TFPLAN" >> "$TFPLAN.out"

  f_log "Terraform plan file created at terraform/$TFPLAN."

  popd
}

terraform_testplan() {
  __WORKSPACE=$1
  __TF_WORKING_DIR=$2

  terraform_init $__WORKSPACE $__TF_WORKING_DIR

  pushd $__TF_WORKING_DIR

  build_var_file_args 4 $@

  f_log "Running Terraform plan..."
  terraform plan -no-color -input=false $VAR_FILES

  popd
}

terraform_apply() {
  __WORKSPACE=$1
  __TF_WORKING_DIR=$2
  __COMMIT_HASH=$3
  __POST_APPLY_FN=${4:-}

  terraform_init $__WORKSPACE $__TF_WORKING_DIR

  pushd $__TF_WORKING_DIR

  TFPLAN="tfplan-$__WORKSPACE-$__COMMIT_HASH"
  
  f_log "Calling Terraform apply on terraform/$TFPLAN"
  terraform apply -no-color "$TFPLAN"

  if [ ! -z $__POST_APPLY_FN ]
  then
    $__POST_APPLY_FN
  fi
  
  f_log "Terraform successfully applied changes, $TFPLAN deployed."

  popd
}

terraform_destroy_testplan() {
  __WORKSPACE=$1
  __TF_WORKING_DIR=$2

  terraform_init $__WORKSPACE $__TF_WORKING_DIR

  pushd $__TF_WORKING_DIR

  build_var_file_args 4 $@

  f_log "Running Terraform plan for destroy..."
  terraform plan -destroy -no-color -input=false $VAR_FILES

  popd
}

terraform_destroy_plan() {
  __WORKSPACE=$1
  __TF_WORKING_DIR=$2
  __COMMIT_HASH=$3

  terraform_init $__WORKSPACE $__TF_WORKING_DIR

  pushd $__TF_WORKING_DIR

  TFPLAN_DESTROY="tfplan-$__WORKSPACE-destroy-$__COMMIT_HASH"
  rm -rf $TFPLAN_DESTROY

  build_var_file_args 5 $@

  f_log "Creating Terraform plan (to destroy) file..."
  terraform plan -destroy -no-color -input=false $VAR_FILES -out="$TFPLAN_DESTROY" >> "$TFPLAN_DESTROY.out"

  f_log "Terraform plan file (to destroy) created at terraform/$TFPLAN_DESTROY."

  popd
}

terraform_destroy() {
  __WORKSPACE=$1
  __TF_WORKING_DIR=$2
  __COMMIT_HASH=$3
  __POST_DESTROY_FN=${4:-}

  terraform_init $__WORKSPACE $__TF_WORKING_DIR

  pushd $__TF_WORKING_DIR

  TFPLAN_DESTROY="tfplan-$__WORKSPACE-destroy-$__COMMIT_HASH"

  f_log "Calling Terraform apply on terraform/$TFPLAN_DESTROY"
  terraform apply -no-color "$TFPLAN_DESTROY"

  if [ ! -z $__POST_DESTROY_FN ]
  then
    $__POST_DESTROY_FN
  fi
  
  f_log "Terraform successfully destroyed $__WORKSPACE infrastructure"

  popd
}

build_app_tfvars_file() {
  __WORKSPACE=$1
  __APP_NAME=$2
  __COMMIT_HASH=$3
  __PLAYBOOK_PATH=$4

  TMP_PATH="/tmp/$__APP_NAME-$__WORKSPACE-$__COMMIT_HASH"
  virtualenv $TMP_PATH
  source "$TMP_PATH/bin/activate"

  pip install -r $__BUILD_TOOLS_PATH/scripts/app-tfvars-requirements.txt
  echo "[local]" > inventory/local
  echo "localhost" >> inventory/local
  echo "[tag_environment_$__WORKSPACE]" >> inventory/local
  echo "localhost" >> inventory/local
  echo "[secrets_$__WORKSPACE]" >> inventory/local
  echo "localhost" >> inventory/local
  ansible-playbook --connection local --inventory inventory/local -e "env=$__WORKSPACE" $__PLAYBOOK_PATH

  f_log "Successfully created terraform $__WORKSPACE vars file."
}

get_current_asg_desired_value() {
  __WORKSPACE=$1
  __TF_WORKING_DIR=$2
  __REGION=$3
  __F_GET_ASG_NAME=$4
  __AWS_ROLE_ARN=$5

  pushd $__TF_WORKING_DIR

  terraform_init $__WORKSPACE $__TF_WORKING_DIR

  if [ -z "$(terraform state list)" ]; then
    f_log "New environment, using the default value for DESIRED when creating the new ASG"
  else
    set_aws_credentials $__AWS_ROLE_ARN
    set +e
    f_log "Existing environment, trying to preserve the current DESIRED value on the ASG"

    _ASG_NAME=$($__F_GET_ASG_NAME)

    _ASG_QUERY_OUTPUT=$(AWS_DEFAULT_REGION=$__REGION aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $_ASG_NAME --output json)
    _ASG_DESIRED_CURRENT=$(echo $_ASG_QUERY_OUTPUT | jq .AutoScalingGroups[0].DesiredCapacity)
    if [ "$_ASG_DESIRED_CURRENT" = "null" ]; then
      _ASG_DESIRED_CURRENT=0
    fi
    f_log "Desired is currently $_ASG_DESIRED_CURRENT"

    if ! [ "$_ASG_DESIRED_CURRENT" -eq 0 ];
    then
      ___ASG_DESIRED=$_ASG_DESIRED_CURRENT
    fi
    set -e
    reset_aws_credentials
  fi

  popd
}

