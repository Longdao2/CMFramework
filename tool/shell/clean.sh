# export SHELL_DIR
# export OUT_DIR
# export REPORT_HTML
# export DOC_DIR
# export PROJ_RAW


source $SHELL_DIR/common.sh

echo "check=3" > $DEPC_FILE
list="$(ls -d $OUT_DIR -f $REPORT_HTML $DOC_DIR/$PROJ_RAW""_ccov.* 2>/dev/null)"

if ! [ "$list" = "" ]; then

  process_start clean

  for path in $list; do
    message_red "Removing $path"
  done

  rm -rf $list
  process_end clean

fi
