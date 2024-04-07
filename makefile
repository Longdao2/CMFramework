#=================================================================================#
# File         makefile                                                           #
# Author       Long Dao                                                           #
# About        https://louisvn.com                                                #
# Version      1.0.9                                                              #
# Release      04-10-2024                                                         #
# Details      C/C++ project management tool - [MK] Main                          #
#=================================================================================#

#---------------------------------------------------------------------------------#
#                                   Definitions                                   #
#---------------------------------------------------------------------------------#

# Path to your project (start at BASE_DIR)
  PROJ_NAME := 0

# Set bash as default console to run commands
  SHELL := bash

# Used to perform an action with a recursive target
  MAKE := make --silent

# Define the colors to display on the console
  ECHO         :=  echo -e
  RED          :=  \033[0;31m
  GREEN        :=  \033[0;32m
  BLUE         :=  \033[0;34m
  GRAY         :=  \033[38;2;97;97;97m
  REVERSE      :=  \033[7m
  RCOLOR       :=  \033[0m

# Only to be used during the build process
  BUILD_VAL    := 0

# Base paths (start at Framework folder)
  ROOT_DIR     :=  $(shell [[ "$$OSTYPE" =~ ^(cygwin|msys)$$ ]] && cygpath -m `pwd` || pwd)
  BASE_DIR     :=  $(ROOT_DIR)/project
  TOOL_DIR     :=  $(ROOT_DIR)/tool
  SHELL_DIR    :=  $(ROOT_DIR)/tool/shell
  SHARE_DIR    :=  $(ROOT_DIR)/share

  TEMP_NAME    :=  0
  TEMP_DIR     :=  $(BASE_DIR)/$(TEMP_NAME)
  PROJ_DIR     :=  $(BASE_DIR)/$(PROJ_NAME)
  OUT_DIR      :=  $(PROJ_DIR)/out
  DOC_DIR      :=  $(PROJ_DIR)/doc
  PROJ_RAW     :=  ~$(subst /,~,$(PROJ_NAME))
  PROJ_EXE     :=  $(OUT_DIR)/$(PROJ_RAW).exe
  GCOVR_EXE    :=  gcovr
  START_EXE    :=  cygstart

# Path to report files
  LOG_FILE     :=  $(OUT_DIR)/$(PROJ_RAW).log
  REPORT_RAW   :=  $(OUT_DIR)/$(PROJ_RAW).ret
  REPORT_HTML  :=  $(DOC_DIR)/$(PROJ_RAW).html
  CCOV_HTML    :=  $(DOC_DIR)/$(PROJ_RAW)_ccov.html
  CHK_FILE     :=  $(TOOL_DIR)/tmp/$(PROJ_RAW)~chk
  CCD_FILE     :=  $(TOOL_DIR)/tmp/$(PROJ_RAW)~ccd
  ASD_FILE     :=  $(TOOL_DIR)/tmp/$(PROJ_RAW)~asd
  LDD_FILE     :=  $(TOOL_DIR)/tmp/$(PROJ_RAW)~ldd

#---------------------------------------------------------------------------------#
#                                      User                                       #
#---------------------------------------------------------------------------------#

  include $(PROJ_DIR)/user_cfg.mk

#---------------------------------------------------------------------------------#
#                                    Validate                                     #
#---------------------------------------------------------------------------------#

ifeq ($(MAKELEVEL),0)

# Broken if the template project no longer exists
ifeq ("$(wildcard $(TEMP_DIR)/user_cfg.mk)","")
  $(error Serious! Template project no longer exists, this framework is broken)
endif

# If the project directory is empty, should be "./path/to/project"
ifeq ("$(wildcard $(PROJ_DIR)/user_cfg.mk)","")
  SILENT := $(shell $(SHELL) $(SHELL_DIR)/actions.sh move $(TEMP_NAME))
  $(error Project [$(PROJ_NAME)] has ceased to exist. So it was brought back to the template project)
endif

# Check input parameters are valid
ifneq ($(filter move.% remove.% import.% export.%, $(MAKECMDGOALS)),)
  ifneq ($(words $(MAKECMDGOALS)),1)
    $(error You can only use the option [move], [remove], [import] or [export] individually)
  endif # MAKECMDGOALS
endif # MAKECMDGOALS

# Some features are limited on the template project
ifeq ($(PROJ_NAME), $(TEMP_NAME))
  override EXC_MAKECMDGOALS := quick force build _build run debug report %.o $(PROJ_EXE) $(OUT_DIR)
  ifneq ($(filter $(EXC_MAKECMDGOALS) !w!0, $(MAKECMDGOALS) !w!$(words $(MAKECMDGOALS))),)
    $(error Some features are limited on template project. Please create or move to another project)
  endif
endif # PROJ_NAME == TEMP_NAME

ifeq ($(shell [[ "$(MAX_PROCESS)" -gt 0 ]] &>/dev/null || echo 1), 1)
  $(error The maximum number of parallel processes must be greater than 0. [MAX_PROCESS = $(MAX_PROCESS)])
endif # MAX_PROCESS < 1

endif # MAKELEVEL == 0

#---------------------------------------------------------------------------------#
#                                     Export                                      #
#---------------------------------------------------------------------------------#

ifeq ($(MAKELEVEL),0)
  include $(TOOL_DIR)/make/export.mk

  USER_DEFS := $(sort $(CCDEFS) $(ASDEFS))
  USER_ENVS := $(sort $(USER_ENVS) REPORT_RAW USER_NAME PROJ_NAME)
  EXPS := $(sort $(EXP) $(USER_ENVS) $(addprefix DEF,$(USER_DEFS)))

  export $(EXPS)
endif # MAKELEVEL == 0

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
  OBJ_FILES += $(foreach SRC_DIR, $(SRC_DIRS), $(wildcard $(SRC_DIR)/*.o))
  SRC_FILES += $(foreach SRC_DIR, $(SRC_DIRS), $(wildcard $(SRC_DIR)/*.[cCsS] $(SRC_DIR)/*.cc $(SRC_DIR)/*.cpp))
  OBJ_AVAIS := $(strip $(OBJ_FILES))

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

ifeq ($(MAKELEVEL),0)
  override OBJ_DUPES := $(shell echo $(OBJ_FILES) $(PROJ_EXE:%.exe=%.o) | tr ' ' '\n' | tr '[:upper:]' '[:lower:]' | sort | uniq -d)
  ifneq ($(bypass),on)
    ifneq ($(OBJ_DUPES),)
      $(info Some object file names have been detected to duplicated after analysis) $(info ---)
      $(foreach OBJ_DUPE, $(OBJ_DUPES), $(info $(OBJ_DUPE))) $(info ---)
      $(error Please check all source files [make bypass=on print.SRC_FILES.OBJ_AVAIS])
    endif # OBJ_DUPES != ""
  endif # bypass != on
endif # MAKELEVEL == 0

# Add prefix to the directory containing the header file
  MASK_INC_DIRS := $(addprefix -I,$(INC_DIRS))

# Definitions for testing
  DEF_RUN_CCOV := $(if $(filter $(RUN_CCOV),on),1,0)
  CCDEFS += RUN_CCOV
  CCOPTS += -DUTEST_SUPPORT

# Add user definitions
  CCOPTS += $(foreach USER_DEF, $(CCDEFS), $(call usr_define, $(USER_DEF)))
  ASOPTS += $(foreach USER_DEF, $(ASDEFS), $(call usr_define, $(USER_DEF)))

ifeq ($(MAKELEVEL),0)
  ifneq ($(bypass),on)
    ifneq ($(words $(CCDEFS) UTEST_SUPPORT) $(words $(ASDEFS)), $(words $(sort $(CCDEFS) UTEST_SUPPORT)) $(words $(sort $(ASDEFS))))
      $(warning Some duplicate user definitions were detected)
      $(error Please check all -D flags in the compiler options [make bypass=on print.CCOPTS.ASOPTS])
    endif
  endif # bypass != on
endif # MAKELEVEL == 0

# Definitions for the code coverage feature
ifeq ($(RUN_CCOV), on)
  CCOV_CC += -fprofile-arcs -ftest-coverage
  CCOV_LD += -lgcov --coverage
endif # RUN_CCOV == on

# List of dependencies to re-compile and re-link
  LIST_CCD := $(strip $(CCOPTS) $(CCOV_CC))
  LIST_ASD := $(strip $(ASOPTS))
  LIST_LDD := $(strip $(LDOPTS) $(CCOV_LD) $(OBJ_AVAIS))

# Config for each programming language
ifeq ($(CC_PATH),) # Default
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
  .PHONY: quick force setup info clean build run debug report vsinit list \
          move.% remove.% import.% export.% print.%

# Extension rules (Please do not use them directly)
  .PHONY: _build _s_build _check_depend

  BUILD_CHECK := $(OUT_DIR) _check_depend
  include $(TOOL_DIR)/make/rules.mk

#---------------------------------------------------------------------------------#
#                                   Dependencies                                  #
#---------------------------------------------------------------------------------#

ifneq ($(bypass),on)
  ifneq ($(filter _build %.o $(PROJ_EXE), $(MAKECMDGOALS)),)
    -include $(PROJ_EXE:%.exe=%.d)
    SRC_DEPS := $(addprefix $(OUT_DIR)/,$(notdir $(shell echo "$(filter-out $(SRC_FILES), $(SRC_PREV))" | sed 's/\.[^.]*\(\s\|$$\)/.\* /g')))
    SILENT := $(shell $(if $(SRC_DEPS), rm -rf $(SRC_DEPS) $(PROJ_EXE) & ) $(SHELL) $(SHELL_DIR)/actions.sh depend_init)
    -include $(OBJ_FILES:%.o=%.d)
  endif # MAKECMDGOALS
endif # bypass != on

ifeq ($(MAKELEVEL),0)
  $(info )
endif # MAKELEVEL == 0

#---------------------------------------------------------------------------------#
#                                   End of file                                   #
#---------------------------------------------------------------------------------#
