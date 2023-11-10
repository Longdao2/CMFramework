#=================================================================================#
# File         makefile                                                           #
# Author       Long Dao                                                           #
# About        https://louisvn.com                                                #
# Version      1.0.6                                                              #
# Release      11-10-2023                                                         #
# Copyright    2023 (c) Belongs to Louisvn                                        #
# Details      C/C++ project management tool - [MK] Main                          #
#=================================================================================#

#---------------------------------------------------------------------------------#
#                                   Definitions                                   #
#---------------------------------------------------------------------------------#

# Path to your project (start at BASE_DIR)
  PROJ_NAME := exam/hello_world

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
  ROOT_DIR     :=  $(shell pwd | sed -e 's/^\(\/cygdrive\)*\/\(.\)/\2:/')
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
  PROJ_EXE     :=  $(OUT_DIR)/$(PROJ_RAW).exe
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
  ASD_FILE     :=  $(SHELL_DIR)/tmp/$(PROJ_RAW)_asd.sh
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
  SILENT := $(shell $(SHELL_DIR)/actions.sh move $(TEMP_NAME))
  $(error Project [$(PROJ_NAME)] has ceased to exist. So it was brought back to the template project)
endif

# Check input parameters are valid
ifneq ($(filter move.% remove.% import.% export.%, $(MAKECMDGOALS)),)
  ifneq ($(words $(MAKECMDGOALS)),1)
    $(error You can only use the option [move], [remove], [import] or [export] individually)
  endif # MAKECMDGOALS
endif # MAKECMDGOALS

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

# List of source code files that do not support debugging
  SRC_NODEBUG_FILES += utest.c

# Search all source files in the project
  OBJ_FILES := $(filter %.o, $(SRC_FILES))
  SRC_FILES := $(filter %.c %.C %.s %.S %.cc %.cpp, $(SRC_FILES))
  SRC_FILES += $(foreach SRC_DIR, $(SRC_DIRS), $(wildcard $(SRC_DIR)/*.[cCsS] $(SRC_DIR)/*.cc $(SRC_DIR)/*.cpp))
  OBJ_FILES += $(foreach SRC_DIR, $(SRC_DIRS), $(wildcard $(SRC_DIR)/*.o))
  OBJ_AVAIL := $(strip $(OBJ_FILES))

  vpath %.c   $(sort $(dir $(SRC_FILES)))
  vpath %.C   $(sort $(dir $(SRC_FILES)))
  vpath %.s   $(sort $(dir $(SRC_FILES)))
  vpath %.S   $(sort $(dir $(SRC_FILES)))
  vpath %.cc  $(sort $(dir $(SRC_FILES)))
  vpath %.cpp $(sort $(dir $(SRC_FILES)))
  vpath %.o   $(sort $(dir $(OBJ_FILES)))

# Parsing file names in the project
  OBJ_NAMES := $(addsuffix .o,$(notdir $(SRC_FILES)))
  OBJ_FILES += $(addprefix $(OUT_DIR)/,$(OBJ_NAMES))
  OBJ_DUPES := $(shell echo $(OBJ_FILES) $(PROJ_EXE:%.exe=%.o) | tr ' ' '\n' | tr '[:upper:]' '[:lower:]' | sort | uniq -d)

ifneq ($(force),on)
  ifneq ($(OBJ_DUPES),)
    $(info Some object file names have been detected to duplicated after analysis) $(info ---)
    $(foreach OBJ_DUPE, $(OBJ_DUPES), $(info $(OBJ_DUPE))) $(info ---)
    $(error Please check all source files [make force=on print.SRC_FILES.OBJ_AVAIL])
  endif # OBJ_DUPES != ""
endif # force != on

# Add prefix to the directory containing the header file
  MASK_INC_DIRS := $(addprefix -I,$(INC_DIRS))

# Add user definitions
  CCOPTS += $(USER_DEFS)
  ASOPTS += $(USER_DEFS)

# Definitions for testing
  CCOPTS += -DUTEST_SUPPORT -DRUN_CCOV=$(if $(filter $(RUN_CCOV),on),1,0)

# Definitions for the code coverage feature
ifeq ($(RUN_CCOV), on)
  CCOV_CC += -fprofile-arcs -ftest-coverage
  CCOV_LD += -lgcov --coverage
endif # RUN_CCOV == on

# List of dependencies to re-compile and re-link
LIST_CCD := $(strip $(CCOPTS) $(CCOV_CC))
LIST_ASD := $(strip $(ASOPTS))
LIST_LDD := $(strip $(LDOPTS) $(CCOV_LD) $(OBJ_AVAIL))

# Config for each programming language (Default)
ifeq ($(CC_PATH),)
  CC_EXE := gcc
  AS_EXE := gcc
  PP_EXE := g++
  DB_EXE := gdb
else # CC_PATH != ""
  CC_EXE := $(CC_PATH)/bin/gcc.exe
  AS_EXE := $(CC_PATH)/bin/gcc.exe
  PP_EXE := $(CC_PATH)/bin/g++.exe
  DB_EXE := $(CC_PATH)/bin/gdb.exe
endif # CC_PATH == ""
  LD_EXE := $(if $(filter %.C %.cc %.cpp, $(SRC_FILES)), $(PP_EXE), $(CC_EXE))

#---------------------------------------------------------------------------------#
#                                      Rules                                      #
#---------------------------------------------------------------------------------#

# All rules
  .PHONY: quick force setup info clean build run report vsinit list \
          move.% remove.% import.% export.% print.%

# Extension rules (Please do not use them directly)
  .PHONY: _all _s_build _check_project _check_depend

  BUILD_CHECK := _check_project $(OUT_DIR) _check_depend
  include $(TOOL_DIR)/make/rules.mk

#---------------------------------------------------------------------------------#
#                                   Dependencies                                  #
#---------------------------------------------------------------------------------#

ifneq ($(force),on)
  ifneq ($(filter quick build %.o $(PROJ_EXE) !w!0, $(MAKECMDGOALS) !w!$(words $(MAKECMDGOALS))),)
    -include $(PROJ_EXE:%.exe=%.d)
    SRC_DEPS := $(addprefix $(OUT_DIR)/,$(notdir $(shell echo "$(filter-out $(SRC_FILES), $(SRC_PREV))" | sed 's/\.[^.]*\(\s\|$$\)/.\* /g')))
    SILENT := $(shell $(if $(SRC_DEPS), rm -rf $(SRC_DEPS) $(PROJ_EXE) & ) $(SHELL_DIR)/actions.sh depend_init)
    -include $(OBJ_FILES:%.o=%.d)
  endif # MAKECMDGOALS
  $(info )
endif # force != on

#---------------------------------------------------------------------------------#
#                                   End of file                                   #
#---------------------------------------------------------------------------------#
