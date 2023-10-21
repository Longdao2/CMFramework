#=================================================================================#
# File         apis.sh                                                            #
# Author       Long Dao                                                           #
# About        https://louisvn.com                                                #
# Version      1.0.3                                                              #
# Update       10-04-2023                                                         #
# Copyright    2023 (c) Belongs to Louisvn                                        #
# Details      C/C++ project management tool - [SH] Apis                          #
#=================================================================================#

#---------------------------------------------------------------------------------#
#                                    Functions                                    #
#---------------------------------------------------------------------------------#

# =================================================================================
# Func   : process_start
# Brief  : Used to print a message for initializing a process
# Params : [1] name_process
# Return : /None/
#
function process_start() {  #  
  $ECHO "$INVERT<<< Start $1 $RCOLOR\n"
}

# =================================================================================
# Func   : process_end
# Brief  : Used to print a message for the completion of a process
# Params : [1] name_process
# Return : /None/
#
function process_end() {  #  name_process
  $ECHO "$GRAY $INVERT"
  date +">>> Finish $1 at "%H:%M:%S" on "%Y-%m-%d" "
  $ECHO "$RCOLOR"
}

# =================================================================================
# GFunc  : message_error | message_red | message_green | message_blue
# Brief  : Used to display a message on the screen
# Params : [1] message
# Return : /None/
#
function message_error() { $ECHO "$RED~ ERROR: $1 $RCOLOR"; }
function message_red  () { $ECHO "$RED>$RCOLOR $1";         }
function message_green() { $ECHO "$GREEN>$RCOLOR $1";       }
function message_blue () { $ECHO "$BLUE>$RCOLOR $1";        }

# =================================================================================
# Func   : gen_ccov
# Brief  : Used to generate a report for code coverage
# Params : /None/
# Return : /None/
#
function gen_ccov() {
  message_green "Generating ccov report to $CCOV_HTML" & \
  $GCOVR_EXE --root $DEV_DIR --object-directory $OUT_DIR --html-details $CCOV_HTML || \
  message_error "CCOV report generation failed"
}

# =================================================================================
# Func   : open_report
# Brief  : Used to open an HTML file with the default web browser
# Params : [1] name_report . [2] url
# Return : /None/
#
function open_report() {
  if [ -e "$2" ] && [ "$SHOW_REPORT" = "on" ]; then
    message_blue "Opening $1 report in browser" & \
    $START_EXE "$2" || message_error "Cannot open [$2]"
  fi
}

# =================================================================================
# Func   : user_response
# Brief  : Used to display a message and prompt for user input [Y/N]
# Params : [1] message
# Return : 0 if the user chooses Y . 1 if the user chooses N
#
function user_response() {
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

# =================================================================================
# Func   : move_project
# Brief  : Used to move to a different project
# Params : [1] old_project . [2] new_project
# Return : /None/
#
function move_project() {  #  from | to
  message_blue "Moving [$1] -> [$2]" & \
  sed -i -e "s/^\s*PROJ_NAME\s*:*=.*$/  PROJ_NAME := ${2//\//\\/}/g" $ROOT_DIR/makefile & \
  $MAKE PROJ_NAME="$2" __forced=on vsinit
}

#---------------------------------------------------------------------------------#
#                                   End of file                                   #
#---------------------------------------------------------------------------------#
