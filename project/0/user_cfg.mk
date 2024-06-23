#=================================================================================#
# File         user_cfg.mk                                                        #
# Author       ...                                                                #
# Version      ...                                                                #
# Release      ...                                                                #
# Details      Specific config for project                                        #
#=================================================================================#

#---------------------------------------------------------------------------------#
#                                    Settings                                     #
#---------------------------------------------------------------------------------#

# Your full name to show in the test report
USER_NAME := Your Full Name

# Run with time out (seconds)
RUN_TIMEOUT := 1.0s

# Run with CCOV report (on/off)
RUN_CCOV := off

# Show the report to the web browser after it is generated (on/off)
SHOW_REPORT := off

# Maximum number of parallel processes for compilation and static code analysis
MAX_PROCESS := 12

#---------------------------------------------------------------------------------#
#                                Paths and options                                #
#---------------------------------------------------------------------------------#

# Declare path to development files here
DEV_DIR := $(PROJ_DIR)/dev

# Declare all paths to source files here
SRC_DIRS := $(PROJ_DIR)/src

# Note: any of the files below shall not be in SRC_DIRS
SRC_FILES := 

# Declare all paths to header files here
INC_DIRS := $(PROJ_DIR)/inc

# Declare all paths to source files for PC-Lint here
PCL_DIRS := 

# Note: any of the files below shall not be in PCL_DIRS
PCL_FILES := $(SRC_FILES)

# Add arguments for the executable to run
VAR_ARGS := 

# Add compiler and linker and PC-Lint options
CCOPTS := -Og -Wall -Wextra -Wwrite-strings -Wshadow=local -pedantic -fmessage-length=0
ASOPTS := -Og -Wall
LDOPTS := -Wl,-Map=$(OUT_DIR)/$(PROJ_RAW).map
PLOPTS := $(LINT_DIR)/co-mwwin32.lnt # -vo

# Separate compiler options for C (C_CCOPTS) and C++ (X_CCOPTS)
C_CCOPTS := 
X_CCOPTS := 

# Separate PC-Lint options for C (C_PLOPTS) and C++ (X_PLOPTS)
C_PLOPTS := 
X_PLOPTS := 

# User definitions. Will also be applied to the VSCode interface and PC-Lint
CCDEFS := 
ASDEFS := 

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
