#!/bin/bash

DEST=$HOME/tmp/profiling.txt
WATCHED_NAMESPACE=${1:-"default"}

on_start() {
  echo "[INFO] Profiling containers in namespace ${WATCHED_NAMESPACE}"
}

on_exit() {
  echo "[INFO] Stopping..."
}

listen_for_q() {
  read -t 0.1 -n 1 key
  if [[ "$key" == "q" ]]; then
    exit 0
  fi
}

runProfiling() {
  while sleep 2; do
      clear
      echo '[RUNNING-2s] oc adm top pods -n default --containers'
      oc adm top pods -n default --containers | tee "$DEST"
      listen_for_q
  done
}

# Register exit hook
trap on_exit EXIT

on_start
runProfiling

exit 0
