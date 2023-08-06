#=================================================================================#
# File         user_cfg.mk                                                        #
# Author       ...                                                                #
# About        ...                                                                #
# Version      1.0.0                                                              #
# Update       00-00-0000                                                         #
# Details      Specific config for project                                        #
#=================================================================================#

#---------------------------------------------------------------------------------#
#                                  Initialization                                 #
#---------------------------------------------------------------------------------#

# Using C++ programming language in the project (on/off)
USE_CPP := off

# Run with time out (seconds)
RUN_TIMEOUT := 30s

# Run with CCOV report (on/off)
RUN_CCOV := off

# Declare path to development files here
DEV_DIR := $(PROJ_DIR)/dev

# Declare all paths to source files (.c .cpp .o) here
SRC_DIRS := $(PROJ_DIR)/src

# Note: any of the files below shall not be in SRC_DIRS
SRC_FILES := 

# Declare all paths to header files (.h) here
INC_DIRS := $(PROJ_DIR)/inc

# Add arguments for the executable to run (if any)
VAR_ARGS := 

# Add user definitions (if any)
USER_DEFS := 

# Add compiler and linker flags (if any)
CCFLAGS := 
LDFLAGS := 

#---------------------------------------------------------------------------------#
#                                   End of file                                   #
#---------------------------------------------------------------------------------#
