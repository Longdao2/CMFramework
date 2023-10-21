#=================================================================================#
# File         report.sh                                                          #
# Author       Long Dao                                                           #
# About        https://louisvn.com                                                #
# Version      1.0.3                                                              #
# Update       10-04-2023                                                         #
# Copyright    2023 (c) Belongs to Louisvn                                        #
# Details      C/C++ project management tool - [SH] Report                        #
#=================================================================================#

#---------------------------------------------------------------------------------#
#                                    Includes                                     #
#---------------------------------------------------------------------------------#

source $SHELL_DIR/apis.sh

#---------------------------------------------------------------------------------#
#                                     Process                                     #
#---------------------------------------------------------------------------------#

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

#---------------------------------------------------------------------------------#
#                                   End of file                                   #
#---------------------------------------------------------------------------------#
