#=================================================================================#
# File         depend.sh                                                          #
# Author       Long Dao                                                           #
# About        https://louisvn.com                                                #
# Version      1.0.3                                                              #
# Update       10-04-2023                                                         #
# Copyright    2023 (c) Belongs to Louisvn                                        #
# Details      C/C++ project management tool - [SH] Depend                        #
#=================================================================================#

#---------------------------------------------------------------------------------#
#                                   Definitions                                   #
#---------------------------------------------------------------------------------#

list_ccd="$CCFLAGS $CCOV_CC"
list_ldd="$LDFLAGS $CCOV_LD"

#---------------------------------------------------------------------------------#
#                                     Process                                     #
#---------------------------------------------------------------------------------#

# =================================================================================
# Case 01 : init
# Details : Check whether the dependencies in the list have been modified, then
#  generate the corresponding test code
#
if [ "$1" = "init" ]; then

  if [ -f $CCD_FILE ]; then source $CCD_FILE; else CCD_DATA=""; fi
  if [ -f $LDD_FILE ]; then source $LDD_FILE; else LDD_DATA=""; fi

  check=0

  if ! [ "$CCD_DATA" = "$list_ccd" ]; then rm -f $OUT_DIR/*.o & (( check += 1 )); fi
  if ! [ "$LDD_DATA" = "$list_ldd" ]; then rm -f $PROJ_OBJ    & (( check += 2 )); fi

  echo "check=$check" > $DEPC_FILE

# =================================================================================
# Case 02 : generate
# Details : Check if the code has been initialized previously. It may then
#  override the dependent files
#
elif [ "$1" = "generate" ]; then

  if [ -f $DEPC_FILE ]; then source $DEPC_FILE; else check=3; fi

  if [ $check = 1 ] || [ $check = 3 ]; then
    echo "CCD_DATA='"$list_ccd"'" > $CCD_FILE
  fi

  if [ $check = 2 ] || [ $check = 3 ]; then
    echo "LDD_DATA='"$list_ldd"'" > $LDD_FILE
  fi

  # Write to the log file information about the timestamp to begin a new build session
  if [ -e $OUT_DIR ]; then
    (echo; echo; date +'========================= '%H:%M:%S' '%Y-%m-%d' ========================='; echo) >> $LOG_FILE
  fi

fi

#---------------------------------------------------------------------------------#
#                                   End of file                                   #
#---------------------------------------------------------------------------------#
