#=================================================================================#
# File         clean.sh                                                           #
# Author       Long Dao                                                           #
# About        https://louisvn.com                                                #
# Version      1.0.3                                                              #
# Update       10-04-2023                                                         #
# Copyright    2023 (c) Belongs to Louisvn                                        #
# Details      C/C++ project management tool - [SH] Clean                         #
#=================================================================================#

#---------------------------------------------------------------------------------#
#                                    Includes                                     #
#---------------------------------------------------------------------------------#

source $SHELL_DIR/apis.sh

#---------------------------------------------------------------------------------#
#                                     Process                                     #
#---------------------------------------------------------------------------------#

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

#---------------------------------------------------------------------------------#
#                                   End of file                                   #
#---------------------------------------------------------------------------------#
