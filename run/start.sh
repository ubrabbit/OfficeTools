#!/bin/bash

set -ex
source ./env.sh

SUPERVISOR_PATH="supervisord"
SUPERVISOR_CTRL_PATH="supervisorctl"

action=$1

function start() {
  $SUPERVISOR_PATH -c "supervisord/supervisord.conf"
  check
}

function check() {
  $SUPERVISOR_CTRL_PATH -c "supervisord/supervisord.conf" status
  return $?
}

function stop() {
  check

  $SUPERVISOR_CTRL_PATH -c "supervisord/supervisord.conf" shutdown
  RESULT=$?
  if [ "RESULT" != "0" ];then
      PIDFILE="${RUN_DIR}/supervisord.pid"
      if [ -f "$PIDFILE" ];then
          cat $PIDFILE | xargs -I{} kill {}
      fi
  fi
  ps -ef | grep "documentserver" | grep -v "grep" | awk '{print $2}' | xargs -I {} kill -9 {}
  echo "stop success"
}

function check_start() {
  check
  RET="$?"
  if [ "$RET" != "0" ];then
    start
  fi
}

output_usage()
{
    echo
    echo "#[USAGE] >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    echo "start.sh start"
    echo "start.sh stop"
    echo "#[USAGE] <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
}

export PATH=$HOME/.local/bin:$PATH

echo "action: ${action}"
cd ${RUN_DIR}
case $action in
  "start")
      start
      ;;
  check)
    check
    ;;
  stop)
    stop
    ;;
  check_start)
    check_start
    ;;
  *)
    output_usage
    ;;
esac
