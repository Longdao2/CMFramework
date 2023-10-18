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

  BUILD_VAL    := 0
  ZIP          ?=

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
ifneq ($(filter move.% remove.% import.% export.%, $(MAKECMDGOALS)),)
  ifneq ($(words $(MAKECMDGOALS)),1)
    $(error You can only use the command [move], [remove], [import] or [export] individually)
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

# Config for each programming language
  CC := gcc
  PP := g++
  LD := $(if $(filter %.cc %.cpp, $(SRC_FILES)), $(PP), $(CC))

# Add compiler flags (if any)
  CCFLAGS += -c -Og -W -Wall -Wextra -Wwrite-strings -Wshadow=local -pedantic -fmessage-length=0
  LDFLAGS += -r

# Definitions for testing
  CCFLAGS += -D UTEST_SUPPORT -D RUN_CCOV=$(if $(filter $(RUN_CCOV),on),1,0)

# Definitions for the code coverage feature
ifeq ($(RUN_CCOV), on)
  CCOV_CC += -fprofile-arcs -ftest-coverage
  CCOV_LD += --coverage
endif # RUN_CCOV == on

#---------------------------------------------------------------------------------#
#                                     Export                                      #
#---------------------------------------------------------------------------------#

export \
  RUN_TIMEOUT   PROJ_EXE      VAR_ARGS      REPORT_RAW    ECHO          RED            \
  GREEN         BLUE          GRAY          INVERT        RCOLOR        ROOT_DIR       \
  BASE_DIR      TOOL_DIR      SHARE_DIR     TEMP_NAME     TEMP_DIR      PROJ_DIR       \
  OUT_DIR       DOC_DIR       PROJ_RAW      PROJ_OBJ      PROJ_EXE      REPORT_EXE     \
  GCOVR_EXE     LOG_FILE      DEPC_FILE     REPORT_RAW    REPORT_HTML   START_EXE      \
  CCOV_HTML     CCD_FILE      LDD_FILE      CC            PP            LD             \
  CCFLAGS       LDFLAGS       CCOV_CC       CCOV_LD       SHELL_DIR     MASK_INC_DIRS  \
  LIST_BUILD    MERGE_2OBJ    LINK_2EXE     USER_NAME     PROJ_NAME     RUN_CCOV       \
  DEV_DIR       SHOW_REPORT

#---------------------------------------------------------------------------------#
#                                      Rules                                      #
#---------------------------------------------------------------------------------#

# All rules
  .PHONY: quick force setup info clean build run report vsinit list \
          move.% remove.% import.% export.% print.%

# Extension rules (Please do not use them directly)
  .PHONY: _all _s_build _check_project _check_depend

# Supports a queue that allows execution across multiple projects
ifneq ($(PROJ_LIST),)
  __forced := on

  ifneq ($(filter move.% remove.% import.% export.%, $(MAKECMDGOALS)),)
    $(error Features [move], [remove], [import] and [export] cannot be used in the list of projects)
  endif # MAKECMDGOALS

$(word 1,$(MAKECMDGOALS)) _all:
	@$(foreach CURR_PROJ, $(PROJ_LIST), $(ECHO) "\n=============== Project: $(CURR_PROJ) ===============" && \
	[ -e $(BASE_DIR)/$(CURR_PROJ)/user_cfg.mk ] && $(MAKE) __forced=off PROJ_LIST="" PROJ_NAME=$(CURR_PROJ) $(MAKECMDGOALS) || \
	( echo && $(call message_error, This project does not exist\n) );)

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
  ifneq ($(filter quick build %.o $(PROJ_EXE) !w!0, $(MAKECMDGOALS) !w!$(words $(MAKECMDGOALS))),)
    SILENT := $(shell $(SHELL_DIR)/depend.sh init)
    -include $(OBJ_FILES:%.o=%.d)
  endif # MAKECMDGOALS
  $(info )
endif # __forced != on

#---------------------------------------------------------------------------------#
#                                   End of file                                   #
#---------------------------------------------------------------------------------#
