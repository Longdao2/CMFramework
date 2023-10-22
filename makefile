#=================================================================================#
# File         makefile                                                           #
# Author       Long Dao                                                           #
# About        https://louisvn.com                                                #
# Version      1.0.5                                                              #
# Release      10-30-2023                                                         #
# Copyright    2023 (c) Belongs to Louisvn                                        #
# Details      C/C++ project management tool - [MK] Main                          #
#=================================================================================#

#---------------------------------------------------------------------------------#
#                                   Definitions                                   #
#---------------------------------------------------------------------------------#

# Path to your project (start at BASE_DIR)
  PROJ_NAME := ~temp

# Set bash as default console to run commands
  SHELL = bash

# Used to perform an action with a recursive target
  MAKE := make --silent

# Define the colors to display on the console
  ECHO         :=  echo -e
  RED          :=  \033[0;31m
  GREEN        :=  \033[0;32m
  BLUE         :=  \033[0;34m
  GRAY         :=  \033[38;2;97;97;97m
  INVERT       :=  \033[7m
  RCOLOR       :=  \033[0m

# Only to be used during the build process
  BUILD_VAL    := 0
  SRC_PREV     :=

# Base paths (start at Framework folder)
  ROOT_DIR     :=  $(shell pwd | sed -e 's/\/cygdrive\/\(.\)/\1:/')
  BASE_DIR     :=  $(ROOT_DIR)/project
  TOOL_DIR     :=  $(ROOT_DIR)/tool
  SHELL_DIR    :=  ./tool/shell
  SHARE_DIR    :=  $(ROOT_DIR)/share

  TEMP_NAME    :=  ~temp
  TEMP_DIR     :=  $(BASE_DIR)/$(TEMP_NAME)
  PROJ_DIR     :=  $(BASE_DIR)/$(PROJ_NAME)
  OUT_DIR      :=  $(PROJ_DIR)/out
  DOC_DIR      :=  $(PROJ_DIR)/doc
  PROJ_RAW     :=  __$(subst /,~,$(PROJ_NAME))

  PROJ_OBJ     :=  $(OUT_DIR)/$(PROJ_RAW).o
  PROJ_EXE     :=  $(OUT_DIR)/$(PROJ_RAW).exe
  REPORT_EXE   :=  $(TOOL_DIR)/bin/report.exe
  GCOVR_EXE    :=  gcovr
  START_EXE    :=  cygstart

# Path to report files
  LOG_FILE     :=  $(OUT_DIR)/$(PROJ_RAW).log
  ERROR_FILE   :=  $(OUT_DIR)/$(PROJ_RAW).err
  REPORT_RAW   :=  $(OUT_DIR)/$(PROJ_RAW).ret
  REPORT_HTML  :=  $(DOC_DIR)/$(PROJ_RAW).html
  CCOV_HTML    :=  $(DOC_DIR)/$(PROJ_RAW)_ccov.html
  DEPC_FILE    :=  $(SHELL_DIR)/tmp/$(PROJ_RAW)_chk.sh
  CCD_FILE     :=  $(SHELL_DIR)/tmp/$(PROJ_RAW)_ccd.sh
  LDD_FILE     :=  $(SHELL_DIR)/tmp/$(PROJ_RAW)_ldd.sh

#---------------------------------------------------------------------------------#
#                                     Export                                      #
#---------------------------------------------------------------------------------#

  include $(TOOL_DIR)/make/export.mk

#---------------------------------------------------------------------------------#
#                                    Validate                                     #
#---------------------------------------------------------------------------------#

# Broken if the template project no longer exists
ifeq ("$(wildcard $(TEMP_DIR)/user_cfg.mk)","")
  $(error Serious! Template project no longer exists, this framework is broken)
endif

# If the project directory is empty, should be "./path/to/project"
ifeq ("$(wildcard $(PROJ_DIR)/user_cfg.mk)","")
  SILENT := $(shell $(SHELL_DIR)/project.sh move $(TEMP_NAME))
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
ifneq ($(filter move.% remove.% import.% export.%, $(MAKECMDGOALS)),)
  ifneq ($(words $(MAKECMDGOALS)),1)
    $(error You can only use the option [move], [remove], [import] or [export] individually)
  endif # MAKECMDGOALS
endif # MAKECMDGOALS

# Search all source files in the project
  SRC_FILES += $(foreach SRC_DIR, $(SRC_DIRS), $(wildcard $(SRC_DIR)/*.c $(SRC_DIR)/*.cc $(SRC_DIR)/*.cpp))
  OBJ_FILES := $(foreach SRC_DIR, $(SRC_DIRS), $(wildcard $(SRC_DIR)/*.o))

# List of source code files that do not support debugging
  SRC_NODEBUG_FILES += utest.c

  vpath %.c   $(sort $(dir $(SRC_FILES)))
  vpath %.cpp $(sort $(dir $(SRC_FILES)))
  vpath %.cc  $(sort $(dir $(SRC_FILES)))
  vpath %.o   $(sort $(dir $(OBJ_FILES)))

# Parsing file names in the project
  OBJ_NAMES := $(notdir $(shell echo "$(SRC_FILES)" | sed 's/\.[^.]*\(\s\|$$\)/.o /g'))
  OBJ_FILES += $(addprefix $(OUT_DIR)/,$(OBJ_NAMES))

# Add prefix to the directory containing the header file
  MASK_INC_DIRS := $(addprefix -I,$(INC_DIRS))

# Config for each programming language
  CC := gcc
  PP := g++
  LD := $(if $(filter %.cc %.cpp, $(SRC_FILES)), $(PP), $(CC))

# Definitions for testing
  CCFLAGS += -DUTEST_SUPPORT -DRUN_CCOV=$(if $(filter $(RUN_CCOV),on),1,0)

# Definitions for the code coverage feature
ifeq ($(RUN_CCOV), on)
  CCOV_CC += -fprofile-arcs -ftest-coverage
  CCOV_LD += --coverage
endif # RUN_CCOV == on

#---------------------------------------------------------------------------------#
#                                      Rules                                      #
#---------------------------------------------------------------------------------#

# All rules
  .PHONY: quick force setup info clean build run report vsinit list \
          move.% remove.% import.% export.% print.%

# Extension rules (Please do not use them directly)
  .PHONY: _all _s_build _check_project _check_depend

# Supports a queue that allows execution across multiple projects
ifneq ($(plist),)
  __forced := on

  ifneq ($(filter move.% remove.% import.% export.%, $(MAKECMDGOALS)),)
    $(error Options [move], [remove], [import] and [export] cannot be used in the list of projects)
  endif # MAKECMDGOALS

$(word 1,$(MAKECMDGOALS)) _all:
	@$(foreach CURR_PROJ, $(plist), $(ECHO) "\n=============== Project: $(CURR_PROJ) ==============="; \
	if [ -e $(BASE_DIR)/$(CURR_PROJ)/user_cfg.mk ]; then $(MAKE) plist="" PROJ_NAME=$(CURR_PROJ) $(MAKECMDGOALS); \
	else echo; $(call message_error, This project does not exist\n); fi; )

$(filter-out $(word 1, $(MAKECMDGOALS)), $(MAKECMDGOALS)):
	@:

# Rules for each project
else # plist == ""
  BUILD_CHECK := _check_project $(OUT_DIR) _check_depend
  include $(TOOL_DIR)/make/rules.mk
endif # plist != ""

#---------------------------------------------------------------------------------#
#                                   Dependencies                                  #
#---------------------------------------------------------------------------------#

ifneq ($(__forced),on)
  ifneq ($(filter quick build %.o $(PROJ_EXE) !w!0, $(MAKECMDGOALS) !w!$(words $(MAKECMDGOALS))),)
    -include $(PROJ_OBJ:%.o=%.d)
    SRC_DEPS := $(addprefix $(OUT_DIR)/,$(notdir $(shell echo "$(filter-out $(SRC_FILES), $(SRC_PREV))" | sed 's/\.[^.]*\(\s\|$$\)/.\* /g')))
    SILENT := $(shell $(if $(SRC_DEPS), rm -rf $(SRC_DEPS) $(PROJ_OBJ) & ) $(SHELL_DIR)/actions.sh depend_init)
    -include $(OBJ_FILES:%.o=%.d)
  endif # MAKECMDGOALS
  $(info )
endif # __forced != on

#---------------------------------------------------------------------------------#
#                                   End of file                                   #
#---------------------------------------------------------------------------------#
