#!/bin/bash
#=================================================================================#
# File         actions.sh                                                         #
# Author       Long Dao                                                           #
# About        https://louisvn.com                                                #
# Version      1.0.9                                                              #
# Release      04-10-2024                                                         #
# Details      C/C++ project management tool - [SH] Actions                       #
#=================================================================================#

#---------------------------------------------------------------------------------#
#                                   Definitions                                   #
#---------------------------------------------------------------------------------#

newproj_name="$2"
newproj_dir="$BASE_DIR/$newproj_name"

vsc_dir=$ROOT_DIR/.vscode
ccpp_file=$TOOL_DIR/tmp/tmp1
launch_file=$TOOL_DIR/tmp/tmp2
setting_file=$TOOL_DIR/tmp/tmp3

#---------------------------------------------------------------------------------#
#                                    Includes                                     #
#---------------------------------------------------------------------------------#

source $SHELL_DIR/apis.sh

#---------------------------------------------------------------------------------#
#                                     Process                                     #
#---------------------------------------------------------------------------------#

case "$1" in

# =================================================================================
# Action: clean
# Detail: Clean all files in project output
#
clean)
  # Reset the check variables of the dependencies to their defaults
  echo "check=abc" > $CHK_FILE &

  # Scan the list of existing output to be removed
  list="$(ls -d $OUT_DIR -f $REPORT_HTML $DOC_DIR/$PROJ_RAW""_ccov.* 2>/dev/null)"

  # If there is at least one output, the cleanup process will start
  if ! [ "$list" = "" ]; then
  process_start clean &

  # Print a message and sequentially remove the outputs
  for path in $list; do
    message_red "Removing $path" & rm -rf $path &
  done

  process_end clean
  fi
;;

# =================================================================================
# Action: depend_init
# Detail: Check for changes in the dependency list
#
depend_init)
  if [ -f $CCD_FILE ]; then CCD_DATA=`cat $CCD_FILE`; else CCD_DATA=""; fi
  if [ -f $ASD_FILE ]; then ASD_DATA=`cat $ASD_FILE`; else ASD_DATA=""; fi
  if [ -f $LDD_FILE ]; then LDD_DATA=`cat $LDD_FILE`; else LDD_DATA=""; fi

  check=""

  if ! [ "$CCD_DATA" = "$LIST_CCD" ]; then rm -f $OUT_DIR/*.c.* $OUT_DIR/*.C.* $OUT_DIR/*.cc.* $OUT_DIR/*.cpp.* & check+=a; fi
  if ! [ "$ASD_DATA" = "$LIST_ASD" ]; then rm -f $OUT_DIR/*.s.* $OUT_DIR/*.S.* & check+=b; fi
  if ! [ "$LDD_DATA" = "$LIST_LDD" ]; then rm -f $OUT_DIR/*.exe $OUT_DIR/*.map & check+=c; fi

  echo -n "$check" > $CHK_FILE &
;;

# =================================================================================
# Action: depend_update
# Detail: Update the dependency list if it was changed previously
#
depend_update)
  if [ -f $CHK_FILE ]; then check=`cat $CHK_FILE`; else check=abc; fi

  if [[ $check =~ a ]]; then
    echo -n "$LIST_CCD" > $CCD_FILE &
  fi

  if [[ $check =~ b ]]; then
    echo -n "$LIST_ASD" > $ASD_FILE &
  fi

  if [[ $check =~ c ]]; then
    echo -n "$LIST_LDD" > $LDD_FILE &
  fi

  # Write to the log file information about the timestamp to begin a new build session
  if [ -e $OUT_DIR ]; then
    (echo; echo; date +'========================= '%H:%M:%S' '%Y-%m-%d' ========================='; echo) >> $LOG_FILE
    # Clear previous warnings and errors
    sed -i 's/^\(\([a-z]:\/\|\)[^\\:*?"<>|]\+\.[a-z]\{1,3\}\(:[0-9]\+:[0-9]\+\|\)\):\( \(warning\|error\): \)/\1.\4/gi' $LOG_FILE &
  fi
;;

# =================================================================================
# Action: check_build
# Detail: Summary of errors and warnings during compilation
#
check_build)
  warns=$(sed -n 's/^\(\([a-z]:\/\|\)[^\\:*?"<>|]\+\.[a-z]\{1,3\}\(:[0-9]\+:[0-9]\+\|\)\):\( warning: \)/&/pgi' $LOG_FILE | wc -l)
  errors=$(sed -n 's/^\(\([a-z]:\/\|\)[^\\:*?"<>|]\+\.[a-z]\{1,3\}\(:[0-9]\+:[0-9]\+\|\)\):\( error: \)/&/pgi' $LOG_FILE | wc -l)
  status=$GREEN"PASS"$RCOLOR
  wc=""
  ec=""

  if [ "$warns" -gt 1 ]; then
    wc="s"
  fi

  if [ "$errors" -gt 0 ]; then
    status=$RED"FAIL"$RCOLOR
    rm -f $OUT_DIR/*.exe $OUT_DIR/*.map &
    if [ "$errors" -gt 1 ]; then
      ec="s"
    fi
  fi

  message_blue "Summary: $errors Error$ec. $warns Warning$wc. [$status] -> $LOG_FILE" &
  echo -e "\n>> Summary: $errors Error$ec. $warns Warning$wc\n" >> $LOG_FILE &
;;

# =================================================================================
# Action: run
# Detail: Run the executable already in the project
#
run)
  process_start run & rm -f $OUT_DIR/*.gcda $REPORT_RAW &

  if [ -e $PROJ_EXE ]; then
    if [ "$DB_SCRIPT" = "" ]; then
      run_cmd normal &
    else
      if !( [ -e $DB_SCRIPT ] && [[ "$DB_SCRIPT" == *.gdb ]] ); then
        message_error "GDB script file does not exist or incorrect format" &
      else
        run_cmd script &
      fi
    fi

  else
    message_error "[$PROJ_EXE] does not exist" &
  fi
  wait
  process_end run
;;

# =================================================================================
# Action: debug
# Detail: Debug the executable already in the project using GDB
#
debug)
  process_start debug & rm -f $OUT_DIR/*.gcda &

  if [ -e $PROJ_EXE ]; then
    $DB_EXE -q -ex "set args ${VAR_ARGS//\\\\/\\}" $PROJ_EXE || :
  else
    message_error "[$PROJ_EXE] does not exist"
  fi

  rm -f $REPORT_RAW &
  process_end debug
;;

# =================================================================================
# Action: report
# Detail: Generate test report after running the program
#
report)
  if ! [ "$(ls -f $OUT_DIR/*.{ret,gcda} 2>/dev/null)" = "" ]; then
    process_start report &

    # Clean old report
    list="$(ls -f $REPORT_HTML $DOC_DIR/$PROJ_RAW""_ccov.* 2>/dev/null)"
    for path in $list; do
      message_red "Removing $path" &
    done
    rm -rf $list &

    # Generate report
    # Test report available
    if [ -e $REPORT_RAW ]; then
      message_green "Generating test report to $REPORT_HTML" &

      if [ "$RUN_CCOV" = "on" ]; then
        gen_test_report $(basename $CCOV_HTML) &
        gen_ccov_report &
      else
        gen_test_report &
      fi
      wait
      open_report "test" "$REPORT_HTML" &

    # Only CCOV report
    elif [ "$RUN_CCOV" = "on" ]; then
      gen_ccov_report &
      wait
      open_report "ccov" "$CCOV_HTML" &
    fi

    wait
    process_end report
  fi
;;

# =================================================================================
# Action: move
# Detail: Move to new project (automatically create if it doesn't exist)
#
move)
  process_start move
  if check_projname; then
    if [ -e "$newproj_dir" ]; then
      if [ -e "$newproj_dir/user_cfg.mk" ]; then
        if [ "$PROJ_NAME" = "$newproj_name" ]; then
          message_green "You are here!" &
        else
          move_project "$PROJ_NAME" "$newproj_name" &
        fi
      else
        message_error "[$newproj_name] is a group of projects!" &
      fi

    else
      if user_responseTF "The [$newproj_name] project does not exist. Do you want to create it?"; then
        message_blue "Cloning $newproj_dir" & mkdir -p $newproj_dir & rm -rf $TEMP_DIR/out &
        cp -Rf $TEMP_DIR/* $newproj_dir &
        move_project "$PROJ_NAME" "$newproj_name" &
      fi
    fi
    wait
  fi
  process_end move
;;

# =================================================================================
# Action: remove
# Detail: Remove an existing project or group
#
remove)
  process_start remove
  if check_projname; then
    if [ -e "$newproj_dir" ]; then
      if [ "$newproj_name" = "$TEMP_NAME" ]; then
        message_error "Cannot remove template [$TEMP_NAME] project" &

      elif user_responseTF "Do you agree to remove this project or group ($newproj_name)?"; then
        message_red "Removing $newproj_dir" &
        rm -r -f $newproj_dir/*; rmdir -p --ignore-fail-on-non-empty $newproj_dir &
        if [[ $PROJ_NAME =~ ^$newproj_name.*$ ]]; then
          move_project "$PROJ_NAME" "$TEMP_NAME" &
        fi
      fi

    else
      message_error "The [$newproj_name] project or group does not exist" &
    fi
    wait
  fi
  process_end remove
;;

# =================================================================================
# Action: import
# Detail: Import a shared project or group from any CMFramework
#
import)
  zip_file="$3"

  process_start import &
  if check_projname; then
    if [[ "$zip_file" == *.zip ]] && ls "$zip_file" 1>/dev/null 2>&1; then
      if [ -e "$newproj_dir" ]; then
        message_error "The [$newproj_name] project or group already exist" &
      else
        message_green "Importing into [$newproj_dir]" &
        mkdir -p $newproj_dir &
        unzip "$zip_file" -d $newproj_dir &
      fi

    else
      message_error "Zip file does not exist or incorrect format" &
    fi
    wait
  fi
  process_end import
;;

# =================================================================================
# Action: export
# Detail: Pack your project or group ready to share
#
export)
  process_start export &
  if check_projname; then
    if [ -e "$newproj_dir" ]; then
      for f in $(find $newproj_dir -type d -name "$(basename $OUT_DIR)"); do
        message_red "Removing $f" & rm -rf $f &
      done

      export_file=$SHARE_DIR/~${newproj_name//\//\~}.zip
      message_green "Compressing to $export_file" &
      rm -f $export_file; cd "$newproj_dir"; zip -r $export_file ./*

    else
      message_error "The [$newproj_name] project or group does not exist" &
    fi
    wait
  fi
  process_end export
;;

# =================================================================================
# Action: vsinit
# Detail: Configure VSCode so that the software links to the correct path
#
vsinit)
  tab="  ""  ""  ""  "

  # Create vscode folder
  mkdir -p $vsc_dir &

  # Clone all configuration files
  cp -f $TOOL_DIR/extend/c_cpp.txt $ccpp_file &
  cp -f $TOOL_DIR/extend/launch.txt $launch_file &
  cp -f $TOOL_DIR/extend/settings.txt $setting_file &
  wait

  # Configuration for settings.json
  sed -i "s|\[\[SED_TEMP_NAME\]\]|$TEMP_NAME|g" "$setting_file" &

  # Configuration for c_cpp_properties.json
  __inc_dirs=""
  for item in $INC_DIRS; do
    __inc_dirs+="\n$tab\"$item\","
  done

  __user_defs=""
  for item in $USER_DEFS; do
    __item="DEF_$item"
    if [ "${!__item}" = "" ]; then
      __user_defs+="\n$tab\"$item\","
    else
      __user_defs+="\n$tab\"$item=$(echo "${!__item}" | sed 's|\\|\\\\\\\\|g; s|"|\\\\"|g; s|\||\\\||g')\","
    fi
  done
  sed -i "s|\[\[SED_INC_DIRS\]\]|$__inc_dirs|g; s|\[\[SED_USER_DEFS\]\]|$__user_defs|g" "$ccpp_file" &

  # Configuration for launch.json
  __var_args=""
  eval "array=(${VAR_ARGS//\\\\/\\\\\\\\})"
  for item in "${array[@]}"; do
    __var_args+="\n$tab\"$(echo $item | sed 's|\\|\\\\\\\\|g; s|\\\\\\\\\\\\\\\\|\\\\\\\\|g; s|"|\\\\\\\\\\\\\\\\\\\\"|g; s|\||\\\||g')\",'"
  done

  __user_envs=""
  for item in $USER_ENVS; do
    __user_envs+="\n$tab{ \"name\": \"$item\", \"value\": \"$(echo ${!item} | sed 's|\\|\\\\\\\\|g; s|"|\\\\"|g; s|\||\\\||g')\" },"
  done
  sed -i "s|\[\[SED_PROJ_EXE\]\]|$PROJ_EXE|g; s|\[\[SED_VAR_ARGS\]\]|$__var_args|g; s|\[\[SED_STOP_ENTRY\]\]|$STOP_AT_ENTRY|g; s|\[\[SED_USER_ENVS\]\]|$__user_envs|g; s|\[\[SED_EXT_CONSOLE\]\]|$EXTERNAL_CONSOLE|g" "$launch_file" &
  wait

  # Move all configuration files
  mv $ccpp_file $vsc_dir/c_cpp_properties.json &
  mv $launch_file $vsc_dir/launch.json &
  mv $setting_file $vsc_dir/settings.json &
;;

# =================================================================================
esac

#---------------------------------------------------------------------------------#
#                                   End of file                                   #
#---------------------------------------------------------------------------------#
