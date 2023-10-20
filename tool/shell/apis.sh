
function process_start() {
  $ECHO "$INVERT<<< Start $1 $RCOLOR\n"
}

function process_end() {
  $ECHO "$GRAY $INVERT"
  date +">>> Finish $1 at "%H:%M:%S" on "%Y-%m-%d" "
  $ECHO "$RCOLOR"
}

function message_error() {
  $ECHO "$RED~ ERROR: $1 $RCOLOR"
}

function message_red() {
  $ECHO "$RED>$RCOLOR $1"
}

function message_green() {
  $ECHO "$GREEN>$RCOLOR $1"
}

function message_blue() {
  $ECHO "$BLUE>$RCOLOR $1"
}

function gen_ccov() {
  message_green "Generating ccov report to $CCOV_HTML" & \
  $GCOVR_EXE --root $DEV_DIR --object-directory $OUT_DIR --html-details $CCOV_HTML || \
  message_error "CCOV report generation failed"
}

function open_report() {  #  name_report | url
  if [ -e "$2" ] && [ "$SHOW_REPORT" = "on" ]; then
    message_blue "Opening $1 report in browser" & \
    $START_EXE "$2" || message_error "Cannot open [$2]"
  fi
}

function user_response() {  #  message
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

function move_project() {  #  from | to
  message_blue "Moving [$1] -> [$2]" & \
  sed -i -e "s/^\s*PROJ_NAME\s*:*=.*$/  PROJ_NAME := ${2//\//\\/}/g" $ROOT_DIR/makefile & \
  $MAKE PROJ_NAME="$2" __forced=on vsinit
}
