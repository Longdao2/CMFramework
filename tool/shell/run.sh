# export SHELL_DIR
# export RUN_TIMEOUT
# export PROJ_EXE
# export VAR_ARGS
# export REPORT_RAW

source $SHELL_DIR/apis.sh

process_start run

if [ -e $PROJ_EXE ]; then

  check=0

  time_start=$(date +%s%N)
  timeout --kill-after=0s $RUN_TIMEOUT $PROJ_EXE $VAR_ARGS && retval=$? || retval=$?
  time_end=$(date +%s%N)

  (( time_diff = (time_end - time_start) / 1000000 - 10 ))

  if [ $retval = 124 ]; then
    message_error "$RUN_TIMEOUT timeout has expired"
  else
    check=1
  fi

  if [ -e "$REPORT_RAW" ]; then
    $ECHO "0.duration = $time_diff\n0.status = $check" >> $REPORT_RAW
  fi

else
  message_error "[$PROJ_EXE] does not exist"
fi

process_end run
