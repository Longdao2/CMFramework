#=================================================================================#
# File         user_cfg.mk                                                        #
# Author       ...                                                                #
# Version      1.0.5                                                              #
# Release      10-30-2023                                                         #
# Copyright    2023 (c) Belongs to Louisvn                                        #
# Details      Specific config for project                                        #
#=================================================================================#

#---------------------------------------------------------------------------------#
#                                     Setting                                     #
#---------------------------------------------------------------------------------#

# Your full name to show in the terminal and test report
USER_NAME := Your Full Name

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

# Declare all paths to source files (.c .cpp .cc .o) here
SRC_DIRS := $(PROJ_DIR)/src

# Note: any of the files below shall not be in SRC_DIRS
SRC_FILES := 

# Declare all paths to header files (.h .hpp .hh) here
INC_DIRS := $(PROJ_DIR)/inc

# Add arguments for the executable to run
VAR_ARGS := 

# Add user environment variables. The declared variables must also be exported
USER_ENVS := REPORT_RAW USER_NAME PROJ_NAME

# Add compiler and linker flags
CCFLAGS := -c -Og -W -Wall -Wextra -Wwrite-strings -Wshadow=local -pedantic -fmessage-length=0
LDFLAGS := -r -Wl,-Map=$(OUT_DIR)/$(PROJ_RAW).map

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
