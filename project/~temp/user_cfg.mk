#=================================================================================#
# File         user_cfg.mk                                                        #
# Author       ...                                                                #
# About        ...                                                                #
# Version      1.0.0                                                              #
# Update       00-00-0000                                                         #
# Details      Specific config for project                                        #
#=================================================================================#

#---------------------------------------------------------------------------------#
#                                     Setting                                     #
#---------------------------------------------------------------------------------#

# Your full name to show in the terminal and test report
USER_NAME := Your Full Name

# Using C++ programming language in the project (on/off)
USE_CPP := off

# Run with time out (seconds)
RUN_TIMEOUT := 30.0s

# Run with CCOV report (on/off)
RUN_CCOV := off

# Show the report to the web browser after it is generated (on/off)
SHOW_REPORT := off

# Show command in terminal [not recommended] (on/off)
SHOW_CMD := off

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

# Add arguments for the executable to run (if any)
VAR_ARGS := 

# Add user definitions (if any)
USER_DEFS := 

# Add compiler and linker flags (if any)
CCFLAGS := 
LDFLAGS := 

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
