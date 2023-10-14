#=================================================================================#
# File         makefile                                                           #
# Author       Long Dao                                                           #
# About        https://louisvn.com                                                #
# Version      1.0.3                                                              #
# Update       10-04-2023                                                         #
# Copyright    2023 (c) Belongs to Louisvn                                        #
# Details      C/C++ project management tool - Main                               #
#=================================================================================#

#---------------------------------------------------------------------------------#
#                                   Definitions                                   #
#---------------------------------------------------------------------------------#

# Path to your project (start at BASE_DIR)
  PROJ_NAME := a

# Set bash as default console to run commands
  SHELL = bash

# Used to perform an action with a recursive target
  MAKE := make --silent

# Define the colors to display on the console
  ECHO    :=  echo -e
  RED     :=  \033[0;31m
  GREEN   :=  \033[0;32m
  BLUE    :=  \033[0;34m
  GRAY    :=  \033[38;2;97;97;97m
  INVERT  :=  \033[7m
  RCOLOR  :=  \033[0m

  BUILD_VAL := 0
  ZIP :=

# Base paths (start at Framework folder)
  ROOT_DIR   :=  $(shell pwd | sed -e 's/\/cygdrive\/\(.\)/\1:/')
  BASE_DIR   :=  $(ROOT_DIR)/project
  TOOL_DIR   :=  $(ROOT_DIR)/tool
  SHARE_DIR  :=  $(ROOT_DIR)/share

  TEMP_NAME  :=  ~temp
  TEMP_DIR   :=  $(BASE_DIR)/$(TEMP_NAME)
  PROJ_DIR   :=  $(BASE_DIR)/$(PROJ_NAME)
  OUT_DIR    :=  $(PROJ_DIR)/out
  DOC_DIR    :=  $(PROJ_DIR)/doc
  PROJ_RAW   :=  __$(subst /,.,$(PROJ_NAME))

  PROJ_OBJ   := $(OUT_DIR)/$(PROJ_RAW).o
  PROJ_EXE   := $(OUT_DIR)/$(PROJ_RAW).exe

# Path to report files
  LOG_FILE     :=  $(OUT_DIR)/$(PROJ_RAW).log
  STATUS_FILE  :=  $(OUT_DIR)/$(PROJ_RAW).err
  REPORT_RAW   :=  $(OUT_DIR)/$(PROJ_RAW).ret
  REPORT_HTML  :=  $(DOC_DIR)/$(PROJ_RAW).html
  CCOV_HTML    :=  $(DOC_DIR)/$(PROJ_RAW)_ccov.html

# Broken if the template project no longer exists
ifeq ("$(wildcard $(TEMP_DIR)/user_cfg.mk)","")
  $(error Serious! Template project no longer exists, this framework is broken)
endif

# If the project directory is empty, should be "./path/to/project"
ifeq ("$(wildcard $(PROJ_DIR)/user_cfg.mk)","")
  SILENT := $(shell $(MAKE) __forced=on PROJ_NAME=$(TEMP_NAME) move.$(TEMP_NAME))
  $(error Project [$(PROJ_NAME)] has ceased to exist. So it was brought back to the template project)
endif

#---------------------------------------------------------------------------------#
#                                      User                                       #
#---------------------------------------------------------------------------------#
  include $(PROJ_DIR)/user_cfg.mk

#---------------------------------------------------------------------------------#
#                                     Macros                                      #
#---------------------------------------------------------------------------------#
  include $(TOOL_DIR)/make/macros.mk

#---------------------------------------------------------------------------------#
#                                    Analysis                                     #
#---------------------------------------------------------------------------------#

# Check input parameters are valid
ifneq ($(filter move.% remove.% import.%, $(MAKECMDGOALS)),)
  ifneq ($(words $(MAKECMDGOALS)),1)
    $(error You can only use the command [move], [remove] or [import] individually)
  endif # MAKECMDGOALS
endif # MAKECMDGOALS

# Search all source files in the project
  SRC_FILES += $(foreach SRC_DIR,$(SRC_DIRS),$(wildcard $(SRC_DIR)/*.c)) \
               $(foreach SRC_DIR,$(SRC_DIRS),$(wildcard $(SRC_DIR)/*.cpp)) \
               $(foreach SRC_DIR,$(SRC_DIRS),$(wildcard $(SRC_DIR)/*.cc))
  OBJ_FILES := $(foreach SRC_DIR,$(SRC_DIRS),$(wildcard $(SRC_DIR)/*.o))

# List of source code files that do not support debugging
  SRC_NODEBUG_FILES += utest.c

# Search all source files
  TLS_OBJ_FILES := $(wildcard $(TOOL_DIR)/bin/obj/*.o)
  TLS_EXE_NAMES := $(notdir $(TLS_OBJ_FILES:%.o=%.exe))

  vpath %.c   $(sort $(dir $(SRC_FILES)))
  vpath %.cpp $(sort $(dir $(SRC_FILES)))
  vpath %.cc  $(sort $(dir $(SRC_FILES)))
  vpath %.o   $(sort $(dir $(OBJ_FILES)) $(TOOL_DIR)/bin/obj)

# Parsing file names in the project
  OBJ_NAMES := $(notdir $(SRC_FILES:%.c=%.o))
  OBJ_NAMES := $(notdir $(OBJ_NAMES:%.cpp=%.o))
  OBJ_NAMES := $(notdir $(OBJ_NAMES:%.cc=%.o))
  OBJ_FILES += $(addprefix $(OUT_DIR)/,$(OBJ_NAMES))

# Add prefix to the directory containing the header file
  MASK_INC_DIRS := $(addprefix -I ,$(INC_DIRS))

# Add compiler flags (if any)
  CCFLAGS += -c -Wall -Wextra -fmessage-length=0
  LDFLAGS += -r

# Definitions for testing
  CCFLAGS +=  -D UTEST_SUPPORT \
              -D "OUTPATH=\"$(REPORT_RAW)\"" \
              -D "USER_NAME=\"$(USER_NAME)\"" \
              -D "PROJ_NAME=\"$(PROJ_NAME)\""

# Definitions for the code coverage feature
ifeq ($(RUN_CCOV), on)
  CCOV_CC += -fprofile-arcs -ftest-coverage
  CCOV_LD += --coverage
endif # RUN_CCOV == on

# Config for each programming language
  CC := gcc
  PP := g++
  LD := $(if $(filter %.cc %.cpp, $(SRC_FILES)), g++, gcc)

#---------------------------------------------------------------------------------#
#                                      Rules                                      #
#---------------------------------------------------------------------------------#

# All rules
  .PHONY: setup quick force info clean build run report status vsinit list \
          move.% remove.% import.% export.% print.%

# Extension rules (Please do not use them directly)
  .PHONY: _all _s_build _check_project _check_depend _s_export

# Supports a queue that allows execution across multiple projects
ifneq ($(PROJ_LIST),)
  __forced := on

$(word 1,$(MAKECMDGOALS)) _all:
	@$(foreach CURR_PROJ, $(PROJ_LIST), \
	$(ECHO) "\n=============== Project: $(CURR_PROJ) ===============" && \
	$(MAKE) __forced=off PROJ_LIST="" PROJ_NAME=$(CURR_PROJ) $(MAKECMDGOALS) || exit 0;)

$(filter-out $(word 1, $(MAKECMDGOALS)), $(MAKECMDGOALS)):
	@:

# Rules for each project
else # PROJ_LIST == ""
  include $(TOOL_DIR)/make/rules.mk
endif # PROJ_LIST != ""

#---------------------------------------------------------------------------------#
#                                   Dependencies                                  #
#---------------------------------------------------------------------------------#

ifneq ($(__forced),on)
  ifneq ($(filter %.o quick force build $(OUT_DIR)/%.o $(PROJ_EXE) !words!0, $(MAKECMDGOALS) !words!$(words $(MAKECMDGOALS))),)
    include $(TOOL_DIR)/make/depend.mk
  endif # MAKECMDGOALS
  $(info )
endif # __forced != on

#---------------------------------------------------------------------------------#
#                                   End of file                                   #
#---------------------------------------------------------------------------------#
