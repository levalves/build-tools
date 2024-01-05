set -eo pipefail

aws configure set cli_timestamp_format iso8601

source "$__BUILD_TOOLS_PATH/scripts/log.sh"

_get_service_properties() {
  _SERVICE_PROPERTIES="$(aws ecs describe-services --cluster $__CLUSTER --region $__REGION --services $__SERVICE_NAME --output json)"
}

_get_primary_desired() {
  _PRIMARY_DESIRED_COUNT=$(echo $_SERVICE_PROPERTIES | jq --raw-output '.services[].deployments[] | select(.status == "PRIMARY") | .desiredCount')
}

_get_primary_running() {
  _PRIMARY_RUNNING_COUNT=$(echo $_SERVICE_PROPERTIES | jq --raw-output '.services[].deployments[] | select(.status == "PRIMARY") | .runningCount')
}

_get_active_running() {
  _ACTIVE_RUNNING_COUNT=$(aws ecs describe-services --cluster $__CLUSTER --region $__REGION --services $__SERVICE_NAME --output json | jq --raw-output '[.services[].deployments[] | select(.status == "ACTIVE") | .runningCount] | reduce .[] as $num (0; .+$num)')
}

_check_events() {
  
  _LAST_STEADY_EVENT_TIMESTAMP=$(aws ecs describe-services --cluster $__CLUSTER --region $__REGION --services $__SERVICE_NAME --output json | jq --raw-output '[.services[].events[] | select( .message | contains ("has reached a steady state.") )][0] | .createdAt')
  if [ "$_LAST_STEADY_EVENT_TIMESTAMP" != "null" ]; then
    _EVENT_TIME=$(date --date="$_LAST_STEADY_EVENT_TIMESTAMP" +"%Y%m%d%H%M%S")
    if [ "$_EVENT_TIME" > "$_START_CHECK_TIME" ]; then
        _STEADY_EVENT_COUNT=1
    fi
  fi
}

check_deployment() {

  __REGION=$1
  __CLUSTER=$2
  __SERVICE_NAME=$3
  __TRIES=${4:-120}

  _START_CHECK_TIME=$(date +"%Y%m%d%H%M%S")

  #Step 1: the desired number of tasks must start successfully using the latest Task Definiton

  _COUNTER=0
  _get_service_properties
  _get_primary_desired
  _get_primary_running

  f_log "Waiting for the NEW TASKS to start..."
  f_log "The service desiredCount is: $_PRIMARY_DESIRED_COUNT"
  f_log "The service current runningCount is: $_PRIMARY_RUNNING_COUNT"

  while [ "$_PRIMARY_RUNNING_COUNT" != "$_PRIMARY_DESIRED_COUNT" ]; do
    _COUNTER=$((_COUNTER+1))
    if [ $_COUNTER -eq 1 ] || [ $(( _COUNTER % 5 )) -eq 0 ]; then
        f_log "Waiting for the new tasks to start..."
    fi
    _get_service_properties
    _get_primary_running
    # waits for 5 successful comparisons to ensure the tasks are really running (the containers may crash shortly after the boot)
    if [ "$_PRIMARY_RUNNING_COUNT" == "$_PRIMARY_DESIRED_COUNT" ]; then
      _PRIMARY_RUNNING_COUNT="0"
      _DOUBLE_CHECK_COUNTER=$((_DOUBLE_CHECK_COUNTER+1))
    fi
    if [[ "$_DOUBLE_CHECK_COUNTER" == "5" ]]; then
      break
    fi
    if [[ $_COUNTER -eq $__TRIES ]]; then
      f_log "Exiting after $__TRIES tries. Deploy FAILED."
      f_log "Reason: The desiredCount was expected to be $_PRIMARY_DESIRED_COUNT but it is currently $_PRIMARY_RUNNING_COUNT."
      exit 1
    fi
  done
  f_log "New tasks were started successfully."

  #Step 2: the tasks running older task definitions must be stopped, 
  #meaning the tasks running the latest task definition passed the health check

  _COUNTER=0
  _get_active_running

  f_log "Waiting for the OLD TASKS to stop..."
  f_log "Number of old tasks still running: $_ACTIVE_RUNNING_COUNT"

  while [ "$_ACTIVE_RUNNING_COUNT" != 0 ]; do
    _COUNTER=$((_COUNTER+1))
    if [ $_COUNTER -eq 1 ] || [ $(( _COUNTER % 5 )) -eq 0 ]; then
        f_log "Waiting for the old tasks to stop..."
    fi
    _get_active_running
    if [[ $_COUNTER -eq $__TRIES ]]; then
      f_log "Exiting after $__TRIES tries. Deploy FAILED."
      f_log "Reason: The number of old tasks was expected to be 0 but it is currently $_ACTIVE_RUNNING_COUNT."
      exit 1
    fi
  done
  f_log "Old tasks stopped successfully."

  #Step 3: a steady event must show up in the events list

  _COUNTER=0
  _STEADY_EVENT_COUNT=0
  _check_events

  f_log "Waiting for the STEADY EVENT to show up in the events list..."

  while [ "$_STEADY_EVENT_COUNT" == 0 ]; do
    _COUNTER=$((_COUNTER+1))
    if [[ $_COUNTER -eq $__TRIES ]]; then
      f_log "Exiting after $__TRIES tries. Deploy FAILED."
      f_log "Reason: The steady event didn't show up in the events list."
      exit 1
    fi
    if [ $_COUNTER -eq 1 ] || [ $(( _COUNTER % 5 )) -eq 0 ]; then
        f_log "Waiting for the steady event to show up..."
    fi
    _check_events
  done

  f_log "Deploy SUCCEEDED. The service is now updated and running the latest task definition."
}
