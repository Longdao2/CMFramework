# export CCD_FILE
# export CCFLAGS
# export OUT_DIR
# export LDD_FILE
# export LDFLAGS
# export PROJ_OBJ
# export DEPC_FILE
# export LOG_FILE


list_ccd="$CCFLAGS $CCOV_CC"
list_ldd="$LDFLAGS $CCOV_LD"

if [ "$1" = "init" ]; then

  if [ -f $CCD_FILE ]; then source $CCD_FILE; else CCD_DATA=""; fi
  if [ -f $LDD_FILE ]; then source $LDD_FILE; else LDD_DATA=""; fi

  check=0

  if ! [ "$CCD_DATA" = "$list_ccd" ]; then rm -f $OUT_DIR/*.o & (( check += 1 )); fi
  if ! [ "$LDD_DATA" = "$list_ldd" ]; then rm -f $PROJ_OBJ    & (( check += 2 )); fi

  echo "check=$check" > $DEPC_FILE

elif [ "$1" = "generate" ]; then

  if [ -f $DEPC_FILE ]; then source $DEPC_FILE; else check=3; fi

  if [ $check = 1 ] || [ $check = 3 ]; then
    echo "CCD_DATA='"$list_ccd"'" > $CCD_FILE
  fi

  if [ $check = 2 ] || [ $check = 3 ]; then
    echo "LDD_DATA='"$list_ldd"'" > $LDD_FILE
  fi

  if [ -e $OUT_DIR ]; then
    (echo; echo; date +'========================= '%H:%M:%S' '%Y-%m-%d' ========================='; echo) >> $LOG_FILE
  fi

fi
