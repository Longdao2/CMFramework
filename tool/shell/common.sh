
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
