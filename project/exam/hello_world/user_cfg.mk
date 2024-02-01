#=================================================================================#
# File         user_cfg.mk                                                        #
# Author       Long Dao                                                           #
# Version      1.0.8                                                              #
# Release      02-15-2024                                                         #
# Details      Specific config for project                                        #
#=================================================================================#

#---------------------------------------------------------------------------------#
#                                    Settings                                     #
#---------------------------------------------------------------------------------#

# Your full name to show in the test report
USER_NAME := Long Dao Hai

# Run with time out (seconds)
RUN_TIMEOUT := 1.0s

# Run with CCOV report (on/off)
RUN_CCOV := off

# Show the report to the web browser after it is generated (on/off)
SHOW_REPORT := off

#---------------------------------------------------------------------------------#
#                                Paths and options                                #
#---------------------------------------------------------------------------------#

# Declare path to development files here
DEV_DIR := $(PROJ_DIR)/dev

# Declare all paths to source files (.[c/s/cc/cpp/o]) here
SRC_DIRS := $(PROJ_DIR)/src

# Note: any of the files below shall not be in SRC_DIRS
SRC_FILES := 

# Declare all paths to header files (.[h/hh/hpp]) here
INC_DIRS := $(PROJ_DIR)/inc

# Add arguments for the executable to run
VAR_ARGS := 

# Add compiler and linker options
CCOPTS := -Og -Wall -Wextra -Wwrite-strings -Wshadow=local -pedantic -fmessage-length=0
ASOPTS := -Og -Wall
LDOPTS := -Wl,-Map=$(OUT_DIR)/$(PROJ_RAW).map

# [-D] User definitions. Will also be applied to the VSCode interface
USER_DEFS := 

# Run the program with the GDB script
DB_SCRIPT := 

# Add user environment variables
USER_ENVS := 

#---------------------------------------------------------------------------------#
#                                   VSCode Debug                                  #
#---------------------------------------------------------------------------------#

# Set default breakpoint at the beginning of main function (true/false)
STOP_AT_ENTRY := true

# Allows the interface to be displayed on an external console window (true/false)
EXTERNAL_CONSOLE := false

#---------------------------------------------------------------------------------#
#                                   End of file                                   #
#---------------------------------------------------------------------------------#
