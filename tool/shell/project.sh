
source $SHELL_DIR/apis.sh

NEWPROJ_NAME="$2"  #  project_name
NEWPROJ_DIR="$BASE_DIR/$NEWPROJ_NAME"

# Move
if [ "$1" = "move" ]; then
  process_start move

  if [ -e "$NEWPROJ_DIR" ]; then
    if [ -e "$NEWPROJ_DIR/user_cfg.mk" ]; then
      if [ "$PROJ_NAME" = "$NEWPROJ_NAME" ]; then
        message_green "You are here!"
      else
        move_project "$PROJ_NAME" "$NEWPROJ_NAME"
      fi
    else
      message_error "[$NEWPROJ_NAME] is a group of projects!"
    fi

  else
    if user_response "The [$NEWPROJ_NAME] project does not exist. Do you want to create it?"; then
      message_blue "Cloning $NEWPROJ_DIR" & mkdir -p $NEWPROJ_DIR & rm -rf $TEMP_DIR/out
      cp -Rf $TEMP_DIR/* $NEWPROJ_DIR
      move_project "$PROJ_NAME" "$NEWPROJ_NAME"
    fi
  fi

  process_end move

# Remove
elif [ "$1" = "remove" ]; then
  process_start remove

  if [ -e "$NEWPROJ_DIR" ]; then
    if [ "$NEWPROJ_NAME" = "$TEMP_NAME" ]; then
      message_error "Cannot remove template [$TEMP_NAME] project"
    elif user_response "Do you agree to remove this project or group ($NEWPROJ_NAME)?"; then
      message_red "Removing $NEWPROJ_DIR" & \
      rm -r -f $NEWPROJ_DIR/*; rmdir -p --ignore-fail-on-non-empty $NEWPROJ_DIR
      if [[ $PROJ_NAME =~ ^$NEWPROJ_NAME.*$ ]]; then
        move_project "$PROJ_NAME" "$TEMP_NAME"
      fi
    fi
  else
    message_error "The [$NEWPROJ_NAME] project or group does not exist"
  fi

  process_end remove

# import
elif [ "$1" = "import" ]; then
  process_start import

  zip_file="$3"
  if [[ "$zip_file" == *.zip ]] && ls $zip_file 1>/dev/null 2>&1; then
    if [ -e "$NEWPROJ_DIR" ]; then
      message_error "The [$NEWPROJ_DIR] project or group already exist"
    else
      message_green "Importing into [$NEWPROJ_DIR]" & \
      mkdir -p $NEWPROJ_DIR
      unzip $zip_file -d $NEWPROJ_DIR
    fi
  else
    message_error "Zip file does not exist or incorrect format"
  fi

  process_end import

# export
elif [ "$1" = "export" ]; then
  process_start export

  if [ -e "$NEWPROJ_DIR" ]; then
    for f in $(find $NEWPROJ_DIR -type d -name "$(basename $OUT_DIR)"); do
      message_red "Removing $f" & rm -rf $f
    done
    export_file=$SHARE_DIR/__${NEWPROJ_NAME//\//\~}.zip
    message_green "Compressing to $export_file" & \
    cd "$NEWPROJ_DIR"; zip -r $export_file ./*
  else
    message_error "The [$NEWPROJ_DIR] project or group does not exist"
  fi

  process_end export
fi
