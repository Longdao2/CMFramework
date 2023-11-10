#=================================================================================#
# File         apis.sh                                                            #
# Author       Long Dao                                                           #
# About        https://louisvn.com                                                #
# Version      1.0.6                                                              #
# Release      11-10-2023                                                         #
# Copyright    2023 (c) Belongs to Louisvn                                        #
# Details      C/C++ project management tool - [SH] Apis                          #
#=================================================================================#

#---------------------------------------------------------------------------------#
#                                    Functions                                    #
#---------------------------------------------------------------------------------#

# =================================================================================
# GFunc  : process_start | process_end
# Brief  : Used to print a message at the start or end of a process
# Params : [1] name_process
# Return : /None/
#
function process_start() {
  $ECHO "$INVERT<<< Start $1 $RCOLOR\n"
}

function process_end() {
  $ECHO "$GRAY $INVERT"
  date +">>> Finish $1 at "%H:%M:%S" on "%Y-%m-%d" "
  $ECHO "$RCOLOR"
}

# =================================================================================
# GFunc  : message_error | message_red | message_green | message_blue
# Brief  : Used to display a message on the screen
# Params : [1] message
# Return : /None/
#
function message_error() { $ECHO "$RED~ ERROR: $1 $RCOLOR"; }
function message_red  () { $ECHO "$RED>$RCOLOR $1";         }
function message_green() { $ECHO "$GREEN>$RCOLOR $1";       }
function message_blue () { $ECHO "$BLUE>$RCOLOR $1";        }

# =================================================================================
# Func   : user_response
# Brief  : Used to display a message and prompt for user input [Y/N]
# Params : [1] message
# Return : 0 if the user chooses Y . 1 if the user chooses N
#
function user_response() {
  while true; do
    $ECHO -n "$GREEN<$RCOLOR $1 [Y/N]: "
    read response
    if   [[ $response =~ ^[Yy]$ ]]; then
      return 0  #  true
    elif [[ $response =~ ^[Nn]$ ]]; then
      return 1  #  false
    fi
  done
}

# =================================================================================
# Func   : move_project
# Brief  : Used to move to a different project
# Params : [1] old_project . [2] new_project
# Return : /None/
#
function move_project() {
  message_blue "Moving [$1] -> [$2]" &
  sed -i -e "s/^\s*PROJ_NAME\s*:*=.*$/  PROJ_NAME := ${2//\//\\/}/g" $ROOT_DIR/makefile &
  $MAKE PROJ_NAME="$2" force=on vsinit
}

# =================================================================================
# Func   : run_cmd
# Brief  : Used to run the program with timeout
# Params : [1] mode (normal|script)
# Return : /None/
#
function run_cmd() {
  time_start=$(date +%s%N)
  if [ "$1" = "normal" ]; then
    eval "array=(${VAR_ARGS})"
    (timeout --kill-after=0s $RUN_TIMEOUT $PROJ_EXE "${array[@]}") && retval=$? || retval=$?
  else
    (timeout --kill-after=0s $RUN_TIMEOUT $DB_EXE -q -batch -ex "set args $VAR_ARGS" -x $DB_SCRIPT $PROJ_EXE) && retval=$? || retval=$?
  fi
  time_end=$(date +%s%N)

  (( time_diff = (time_end - time_start) / 1000000 - 10 ))

  if [ $retval = 124 ]; then
    message_error "$RUN_TIMEOUT timeout has expired" &
  else
    check=1
  fi

  if [ -e "$REPORT_RAW" ]; then
    $ECHO "0.duration = $time_diff\n0.status = $check" >> $REPORT_RAW &
  fi
}

# =================================================================================
# Func   : gen_test_report
# Brief  : Generate a test report from test results (using utest)
# Params : [1] ccov_name
# Return : /None/
#
function gen_test_report() {
  # Get data from the test result file
  function inner_getvar() {  #  test_index | var_name
    sed -n "s/^\s*$1.$2\s*=\s*//p" "$REPORT_RAW"
  }

  dos2unix -q $REPORT_RAW &
  cp -f $TOOL_DIR/extend/report.html $REPORT_HTML

  sed -i "s|\[\[SED_FILE_NAME\]\]|$(basename $REPORT_HTML)|g; s|\[\[SED_REPORT_CCOV\]\]|$1|g; s|\[\[SED_PROJ_NAME\]\]|$(inner_getvar 0 proj_name)|g; s|\[\[SED_USER_NAME\]\]|$(inner_getvar 0 user_name)|g; s|\[\[SED_TIMESTAMP\]\]|$(inner_getvar 0 exe_time)|g; s|\[\[SED_TIME_EXEC\]\]|$(inner_getvar 0 duration)|g; s|\[\[SED_CHECK_STATUS\]\]|$(inner_getvar 0 status)|g" "$REPORT_HTML" &

  buff=""
  all_test=$(inner_getvar 0 all_test)

  for (( i=1; i<=all_test; i++ )); do
    test_name=$(inner_getvar $i name)
    test_brief=$(echo $(inner_getvar $i brief) | sed 's|\\|\\\\|g; s|"|\\"|g; s|\||\\\||g')
    test_status=$(inner_getvar $i status)
    test_duration=$(inner_getvar $i duration)
    test_fail=$(echo $(inner_getvar $i fail) | sed 's|\\|\\\\|g; s|"|\\"|g; s|\||\\\||g')

    buff+='\n    Add_Test("'$test_name'","'$test_brief'","'$test_duration'","'$test_status'","'$test_fail'");'
  done
  sed -i "s|\[\[SED_ADD_ALL_TEST\]\]|$buff|g" "$REPORT_HTML" &
}

# =================================================================================
# Func   : gen_ccov_report
# Brief  : Used to generate a report for code coverage
# Params : /None/
# Return : /None/
#
function gen_ccov_report() {
  message_green "Generating ccov report to $CCOV_HTML" &
  $GCOVR_EXE --root $DEV_DIR --object-directory $OUT_DIR --html-details $CCOV_HTML || \
  message_error "CCOV report generation failed"
}

# =================================================================================
# Func   : open_report
# Brief  : Used to open an HTML file with the default web browser
# Params : [1] name_report . [2] url
# Return : /None/
#
function open_report() {
  if [ -e "$2" ] && [ "$SHOW_REPORT" = "on" ]; then
    message_blue "Opening $1 report in browser" &
    $START_EXE "$2" || message_error "Cannot open [$2]"
  fi
}

#---------------------------------------------------------------------------------#
#                                   End of file                                   #
#---------------------------------------------------------------------------------#
