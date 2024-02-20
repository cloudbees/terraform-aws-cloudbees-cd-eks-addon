#!/usr/bin/env bash

set -euo pipefail

SCRIPTDIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RETRY_SECONDS=10
MSG_INFO="\033[36m[INFO] %s\033[0m\n"

test-all () {
  declare -a bluePrints=(
    "01-getting-started"
    "02-at-scale"
  )
  for bp in "${bluePrints[@]}"
  do
    export ROOT="$bp"
    cd "$SCRIPTDIR"/.. && make test
  done
}``

get-tf-output () {
  local ROOT=$1
  local OUTPUT=$2
  cd "$SCRIPTDIR/$ROOT" && terraform output -raw "$OUTPUT" 2> /dev/null
}

probes-common () {
  local ROOT=$1
  eval "$(get-tf-output "$ROOT" kubeconfig_export)"
  until [ "$(eval "$(get-tf-output "$ROOT" cbcd_flowserver_pod)" | awk '{ print $3 }' | grep -v STATUS | grep -v -c Running)" == 0 ]; do sleep 10 && echo "Waiting for Operation Center Pod to get ready..."; done ;\
    eval "$(get-tf-output "$ROOT" cbcd_flowserver_pod)" && printf "$MSG_INFO" "CD Servver Pod is Ready."
  CD_URL=$(get-tf-output "$ROOT" cbcd_url)
  until eval "$(get-tf-output "$ROOT" cbcd_liveness_probe_ext)"; do sleep $RETRY_SECONDS && echo "Waiting for CD Server to pass Health Check from outside the clustery..."; done ;\
    printf "$MSG_INFO" "CD Server passed Health Check outside the cluster. It is available at $CD_URL."
}

probes-bp01 () {
  local ROOT="01-getting-started"
  eval "$(get-tf-output "$ROOT" kubeconfig_export)"
  INITIAL_PASS=$(eval "$(get-tf-output "$ROOT" cbcd_initial_admin_password)"); \
    printf "$MSG_INFO" "Initial Admin Password: $INITIAL_PASS."
}

probes-bp02 () {
  local ROOT="02-at-scale"
  eval "$(get-tf-output "$ROOT" kubeconfig_export)"
  GENERAL_PASS=$(eval "$(get-tf-output "$ROOT" cbcd_general_password)"); \
    printf "$MSG_INFO" "General Password all users: $GENERAL_PASS."
  eval "$(get-tf-output "$ROOT" velero_backup_schedule_team_a)" && eval "$(get-tf-output "$ROOT" velero_backup_on_demand_team_a)" > "/tmp/backup.txt" && \
		cat "/tmp/backup.txt" | grep "Backup completed with status: Completed" && \
		printf "$MSG_INFO" "Velero backups are working"
}
