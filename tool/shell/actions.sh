#=================================================================================#
# File         actions.sh                                                         #
# Author       Long Dao                                                           #
# About        https://louisvn.com                                                #
# Version      1.0.5                                                              #
# Release      10-30-2023                                                         #
# Copyright    2023 (c) Belongs to Louisvn                                        #
# Details      C/C++ project management tool - [SH] Actions                       #
#=================================================================================#

#---------------------------------------------------------------------------------#
#                                    Ingen_ccov_reportcludes                                     #
#---------------------------------------------------------------------------------#

source $SHELL_DIR/apis.sh

#---------------------------------------------------------------------------------#
#                                   Definitions                                   #
#---------------------------------------------------------------------------------#

list_ccd="$CCFLAGS $CCOV_CC"
list_ldd="$LDFLAGS $CCOV_LD"

newproj_name="$2"
newproj_dir="$BASE_DIR/$newproj_name"

vsc_dir="$ROOT_DIR/.vscode"
ccpp_file="$vsc_dir/c_cpp_properties.json"
launch_file="$vsc_dir/launch.json"
setting_file="$vsc_dir/settings.json"

#---------------------------------------------------------------------------------#
#                                     Process                                     #
#---------------------------------------------------------------------------------#

# =================================================================================
# Action: clean
# Detail: Clean all files in project output
#
if [ "$1" = "clean" ]; then
  # Reset the check variables of the dependencies to their defaults
  echo "check=3" > $DEPC_FILE

  # Scan the list of existing output to be removed
  list="$(ls -d $OUT_DIR -f $REPORT_HTML $DOC_DIR/$PROJ_RAW""_ccov.* 2>/dev/null)"

  # If there is at least one output, the cleanup process will start
  if ! [ "$list" = "" ]; then
  process_start clean

  # Print a message and sequentially remove the outputs
  for path in $list; do
      message_red "Removing $path" & rm -rf $path
  done

  process_end clean
  fi

# =================================================================================
# Action: depend_init
# Detail: Check for changes in the dependency list
#
elif [ "$1" = "depend_init" ]; then
  if [ -f $CCD_FILE ]; then source $CCD_FILE; else CCD_DATA=""; fi
  if [ -f $LDD_FILE ]; then source $LDD_FILE; else LDD_DATA=""; fi

  check=0

  if ! [ "$CCD_DATA" = "$list_ccd" ]; then rm -f $OUT_DIR/*.o & (( check += 1 )); fi
  if ! [ "$LDD_DATA" = "$list_ldd" ]; then rm -f $PROJ_OBJ    & (( check += 2 )); fi

  echo "check=$check" > $DEPC_FILE

# =================================================================================
# Action: depend_update
# Detail: Update the dependency list if it was changed previously
#
elif [ "$1" = "depend_update" ]; then
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

# =================================================================================
# Action: run
# Detail: Run the executable already in the project
#
elif [ "$1" = "run" ]; then
  process_start run
  if [ -e $PROJ_EXE ]; then
    check=0

    # Record the start and end times of program execution
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

# =================================================================================
# Action: report
# Detail: Generate test report after running the program
#
elif [ "$1" = "report" ]; then
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
        gen_test_report $(basename $CCOV_HTML)
        gen_ccov_report
      else
        gen_test_report
      fi
      open_report "test" "$REPORT_HTML"

    # Only CCOV report
    elif [ "$RUN_CCOV" = "on" ]; then
      gen_ccov_report
      open_report "ccov" "$CCOV_HTML"
    fi

    process_end report
  fi

# =================================================================================
# Action: move
# Detail: Move to new project (automatically create if it doesn't exist)
#
elif [ "$1" = "move" ]; then
  process_start move
  if [ -e "$newproj_dir" ]; then
    if [ -e "$newproj_dir/user_cfg.mk" ]; then
      if [ "$PROJ_NAME" = "$newproj_name" ]; then
        message_green "You are here!"
      else
        move_project "$PROJ_NAME" "$newproj_name"
      fi
    else
      message_error "[$newproj_name] is a group of projects!"
    fi

  else
    if user_response "The [$newproj_name] project does not exist. Do you want to create it?"; then
      message_blue "Cloning $newproj_dir" & mkdir -p $newproj_dir & rm -rf $TEMP_DIR/out
      cp -Rf $TEMP_DIR/* $newproj_dir
      move_project "$PROJ_NAME" "$newproj_name"
    fi
  fi
  process_end move

# =================================================================================
# Action: remove
# Detail: Remove an existing project or group
#
elif [ "$1" = "remove" ]; then
  process_start remove
  if [ -e "$newproj_dir" ]; then
    if [ "$newproj_name" = "$TEMP_NAME" ]; then
      message_error "Cannot remove template [$TEMP_NAME] project"

    elif user_response "Do you agree to remove this project or group ($newproj_name)?"; then
      message_red "Removing $newproj_dir" & \
      rm -r -f $newproj_dir/*; rmdir -p --ignore-fail-on-non-empty $newproj_dir
      if [[ $PROJ_NAME =~ ^$newproj_name.*$ ]]; then
        move_project "$PROJ_NAME" "$TEMP_NAME"
      fi
    fi

  else
    message_error "The [$newproj_name] project or group does not exist"
  fi
  process_end remove

# =================================================================================
# Action: import
# Detail: Import a shared project or group from any CMFramework
#
elif [ "$1" = "import" ]; then
  process_start import
  zip_file="$3"

  if [[ "$zip_file" == *.zip ]] && ls $zip_file 1>/dev/null 2>&1; then
    if [ -e "$newproj_dir" ]; then
      message_error "The [$newproj_name] project or group already exist"
    else
      message_green "Importing into [$newproj_dir]" & \
      mkdir -p $newproj_dir
      unzip $zip_file -d $newproj_dir
    fi

  else
    message_error "Zip file does not exist or incorrect format"
  fi
  process_end import

# =================================================================================
# Action: export
# Detail: Pack your project or group ready to share
#
elif [ "$1" = "export" ]; then
  process_start export
  if [ -e "$newproj_dir" ]; then
    for f in $(find $newproj_dir -type d -name "$(basename $OUT_DIR)"); do
      message_red "Removing $f" & rm -rf $f
    done

    export_file=$SHARE_DIR/__${newproj_name//\//\~}.zip
    message_green "Compressing to $export_file" & \
    cd "$newproj_dir"; zip -r $export_file ./*

  else
    message_error "The [$newproj_name] project or group does not exist"
  fi
  process_end export

# =================================================================================
# Action: vsinit
# Detail: Configure VSCode so that the software links to the correct path
#
elif [ "$1" = "vsinit" ]; then
  # Create vscode folder
  mkdir -p $vsc_dir

  # Copy all configuration files
  cp -f $TOOL_DIR/extend/c_cpp.txt $ccpp_file
  cp -f $TOOL_DIR/extend/launch.txt $launch_file
  cp -f $TOOL_DIR/extend/settings.txt $setting_file

  # Configuration for settings.json
  sed -i "s|\[\[SED_TEMP_NAME\]\]|$TEMP_NAME|g" "$setting_file"

  # Configuration for c_cpp_properties.json
  buff=""
  for item in $INC_DIRS; do
    buff+='\n        "'$item'",'
  done
  sed -i "s|\[\[SED_INC_DIRS\]\]|$buff|g" "$ccpp_file"

  # Configuration for launch.json
  buff=""
  eval "array=($VAR_ARGS)"
  for item in "${array[@]}"; do
    buff+='\n        "'"$(echo $item | sed 's|\\|\\\\|g; s|"|\\\\"|g; s|\||\\\||g')"'",'
  done
  sed -i "s|\[\[SED_PROJ_EXE\]\]|$PROJ_EXE|g; s|\[\[SED_VAR_ARGS\]\]|$buff|g; s|\[\[SED_STOP_ENTRY\]\]|$STOP_AT_ENTRY|g; s|\[\[SED_EXT_CONSOLE\]\]|$EXTERNAL_CONSOLE|g" "$launch_file"

# =================================================================================
fi

#---------------------------------------------------------------------------------#
#                                   End of file                                   #
#---------------------------------------------------------------------------------#
