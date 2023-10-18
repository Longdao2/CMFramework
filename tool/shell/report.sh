# import
#   SHELL_DIR   OUT_DIR     REPORT_HTML  DOC_DIR     PROJ_RAW
#   REPORT_RAW  RUN_CCOV    REPORT_EXE   CCOV_HTML   GCOVR_EXE
#   DEV_DIR     START_EXE   SHOW_REPORT

source $SHELL_DIR/common.sh

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

if ! [ "$(ls -f $OUT_DIR/*.{ret,gcno} 2>/dev/null)" = "" ]; then

  process_start report

  # Clean old report
  list="$(ls -f $REPORT_HTML $DOC_DIR/$PROJ_RAW""_ccov.* 2>/dev/null)"
  for path in $list; do
    message_red "Removing $path"
  done
  rm -rf $list

  # Generate report
  # Test report available
  if [ -e $REPORT_RAW ]; then
    message_green "Generating test report to $REPORT_HTML"
    if [ "$RUN_CCOV" = "on" ]; then
      $REPORT_EXE $REPORT_RAW $(basename $CCOV_HTML) $REPORT_HTML
      gen_ccov
    else
      $REPORT_EXE $REPORT_RAW "" $REPORT_HTML
    fi
    open_report "test" "$REPORT_HTML"

  # Only CCOV report
  elif [ "$RUN_CCOV" = "on" ]; then
    gen_ccov
    open_report "ccov" "$CCOV_HTML"
  fi

  process_end report

fi
