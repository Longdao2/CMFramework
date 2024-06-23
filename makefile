#=================================================================================#
# File         makefile                                                           #
# Author       Long Dao                                                           #
# About        https://louisvn.com                                                #
# Version      2.0.0                                                              #
# Release      07-01-2024                                                         #
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

# Used only during compilation
  BUILD_VAL    := 0
  SH_SPACE     := " "
  COMMA        := ,

# Environment values
  include tool/make/env.mk

# Base paths (start at Framework folder)
  ROOT_DIR     :=  $(shell [[ "$$OSTYPE" =~ ^(cygwin|msys)$$ ]] && cygpath -m `pwd` || pwd)
  BASE_DIR     :=  $(ROOT_DIR)/project
  TOOL_DIR     :=  $(ROOT_DIR)/tool
  SHELL_DIR    :=  $(TOOL_DIR)/shell
  LIB_DIR      :=  $(TOOL_DIR)/lib
  LINT_DIR     :=  $(TOOL_DIR)/lint
  SHARE_DIR    :=  $(ROOT_DIR)/share
  CC_PATH      :=  $(shell dirname "$$(realpath "`$(WHERE_EXE) $(GCC_NAME) | head -n 1`")")
  PL_PATH      :=  $(shell dirname "$$(realpath "`$(WHERE_EXE) $(PCL_NAME) | head -n 1`")")

  TEMP_NAME    :=  0
  TEMP_DIR     :=  $(BASE_DIR)/$(TEMP_NAME)
  PROJ_DIR     :=  $(BASE_DIR)/$(PROJ_NAME)
  OUT_DIR      :=  $(PROJ_DIR)/out
  DOC_DIR      :=  $(PROJ_DIR)/doc
  PROJ_RAW     :=  ~$(subst /,~,$(PROJ_NAME))
  PROJ_EXE     :=  $(OUT_DIR)/$(PROJ_RAW).exe
  PROJ_TMPEXE  :=  $(TOOL_DIR)/tmp/$(PROJ_RAW).exe

# Path to report files
  LOG_FILE     :=  $(OUT_DIR)/$(PROJ_RAW).log
  REPORT_RAW   :=  $(OUT_DIR)/$(PROJ_RAW).ret
  LINT_C_H     :=  $(OUT_DIR)/$(PROJ_RAW)_c.h
  LINT_CPP_H   :=  $(OUT_DIR)/$(PROJ_RAW)_cpp.h
  LINT_INC     :=  $(OUT_DIR)/$(PROJ_RAW)_inc.lnt
  LINT_SIZE    :=  $(OUT_DIR)/$(PROJ_RAW)_size.lnt
  REPORT_HTML  :=  $(DOC_DIR)/$(PROJ_RAW).html
  CCOV_HTML    :=  $(DOC_DIR)/$(PROJ_RAW)_ccov.html
  ANALYZE_LOG  :=  $(DOC_DIR)/$(PROJ_RAW)_analyze.log
  CHK_FILE     :=  $(TOOL_DIR)/tmp/$(PROJ_RAW)~chk
  CCD_FILE     :=  $(TOOL_DIR)/tmp/$(PROJ_RAW)~ccd
  CXD_FILE     :=  $(TOOL_DIR)/tmp/$(PROJ_RAW)~cxd
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
  endif # -f $(TEMP_DIR)/user_cfg.mk

  # If the project directory is empty, should be "./path/to/project"
  ifeq ("$(wildcard $(PROJ_DIR)/user_cfg.mk)","")
    SILENT := $(shell $(SHELL) $(SHELL_DIR)/actions.sh move $(TEMP_NAME))
    $(error Project [$(PROJ_NAME)] has ceased to exist. So it was brought back to the template project)
  endif # -f $(PROJ_DIR)/user_cfg.mk

  # Check input parameters are valid
  ifneq ($(filter move.% remove.% import.% export.%, $(MAKECMDGOALS)),)
    ifneq ($(words $(MAKECMDGOALS)),1)
      $(error You can only use the option [move], [remove], [import] or [export] individually)
    endif # MAKECMDGOALS
  endif # MAKECMDGOALS

  # Some extension targets will not be supported
  override EXC_TARGETS := _build _s_build _check_depend _s_analyze $(PROJ_EXE) $(OUT_DIR) $(LINT_C_H) \
    $(LINT_CPP_H) $(LINT_INC) $(LINT_SIZE) $(SHARE_DIR)
  ifneq ($(filter $(EXC_TARGETS), $(MAKECMDGOALS)),)
    $(error Some extension targets will not be supported for direct execution)
  endif # EXC_TARGETS

  # Some features are limited on the template project
  ifeq ($(PROJ_NAME), $(TEMP_NAME))
    override EXC_MAKECMDGOALS := quick force build _build run debug report analyze %.o $(PROJ_EXE) $(OUT_DIR)
    ifneq ($(filter $(EXC_MAKECMDGOALS) !w!0, $(MAKECMDGOALS) !w!$(words $(MAKECMDGOALS))),)
      $(error Some features are limited on template project. Please create or move to another project)
    endif # EXC_MAKECMDGOALS
  endif # PROJ_NAME == TEMP_NAME

  # Maximum number of threads applied for code compilation and static code analysis
  ifeq ($(shell [[ "$(MAX_PROCESS)" -gt 0 ]] &>/dev/null || echo 1), 1)
    $(error The maximum number of parallel processes must be greater than 0. [MAX_PROCESS = $(MAX_PROCESS)])
  endif # MAX_PROCESS < 1

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
  OBJ_FILES     :=  $(filter %.o, $(SRC_FILES)) $(foreach SRC_DIR, $(SRC_DIRS), $(wildcard $(SRC_DIR)/*.o))
  OBJ_AVAIS     :=  $(strip $(OBJ_FILES))
  ALL_SRC_FILES :=  $(filter %.cc %.cp %.cxx %.cpp %.c++ %.CPP %.C %.c %.s %.S, $(SRC_FILES)) \
                    $(foreach SRC_DIR, $(SRC_DIRS), $(wildcard $(addprefix $(SRC_DIR)/*., cc cp cxx cpp c++ CPP C c s S)))
  C_PCL_FILES   :=  $(filter %.c, $(PCL_FILES)) \
                    $(foreach PCL_DIR, $(PCL_DIRS), $(wildcard $(PCL_DIR)/*.c))
  CPP_PCL_FILES :=  $(filter %.cc %.cp %.cxx %.cpp %.c++ %.CPP %.C, $(PCL_FILES)) \
                    $(foreach PCL_DIR, $(PCL_DIRS), $(wildcard $(addprefix $(PCL_DIR)/*., cc cp cxx cpp c++ CPP C)))

  vpath %.cc  $(sort $(dir $(ALL_SRC_FILES)))
  vpath %.cp  $(sort $(dir $(ALL_SRC_FILES)))
  vpath %.cxx $(sort $(dir $(ALL_SRC_FILES)))
  vpath %.cpp $(sort $(dir $(ALL_SRC_FILES)))
  vpath %.c++ $(sort $(dir $(ALL_SRC_FILES)))
  vpath %.CPP $(sort $(dir $(ALL_SRC_FILES)))
  vpath %.C   $(sort $(dir $(ALL_SRC_FILES)))
  vpath %.c   $(sort $(dir $(ALL_SRC_FILES)))
  vpath %.s   $(sort $(dir $(ALL_SRC_FILES)))
  vpath %.S   $(sort $(dir $(ALL_SRC_FILES)))
  vpath %.o   $(sort $(dir $(OBJ_FILES)))

# Parsing file names in the project
  OBJ_NONAMES := $(addsuffix .o,$(sort $(shell for i in $(notdir $(ALL_SRC_FILES)); do sed 's/\.[^.]*$$//' <<< $$i; done)))
  OBJ_NAMES   := $(addsuffix .o,$(notdir $(ALL_SRC_FILES)))
  OBJ_FILES   += $(addprefix $(OUT_DIR)/,$(OBJ_NAMES))

ifeq ($(MAKELEVEL),0)
  override OBJ_DUPES := $(shell echo $(OBJ_FILES) $(PROJ_EXE:%.exe=%.o) | tr ' ' '\n' | tr '[:upper:]' '[:lower:]' | sort | uniq -d)
  ifneq ($(bypass),on)
    ifneq ($(OBJ_DUPES),)
      $(info Some object file names have been detected to duplicated after analysis) $(info ---)
      $(foreach OBJ_DUPE, $(OBJ_DUPES), $(info $(OBJ_DUPE))) $(info ---)
      $(error Please check all source files [make bypass=on print.ALL_SRC_FILES.OBJ_AVAIS])
    endif # OBJ_DUPES != ""
  endif # bypass != on
endif # MAKELEVEL == 0

# Add prefix to the directory containing the header file
  MASK_INC_DIRS := $(addprefix -I,$(INC_DIRS))
  PLOPTS += $(addprefix -i,$(INC_DIRS))

# Definitions for testing
  DEF_RUN_CCOV   := $(if $(filter $(RUN_CCOV),on),1,0)
  DEF_REPORT_RAW := "$(REPORT_RAW)"
  DEF_USER_NAME  := "$(USER_NAME)"
  DEF_PROJ_NAME  := "$(PROJ_NAME)"
  CCDEFS += RUN_CCOV REPORT_RAW USER_NAME PROJ_NAME
  CCOPTS += -DUTEST_SUPPORT
  PLOPTS += -dUTEST_SUPPORT

# Add user definitions
  CCOPTS += $(foreach USER_DEF, $(CCDEFS), $(call usr_define, $(USER_DEF), D))
  ASOPTS += $(foreach USER_DEF, $(ASDEFS), $(call usr_define, $(USER_DEF), D))
  PLOPTS += $(foreach USER_DEF, $(CCDEFS), $(call usr_define, $(USER_DEF), d))

# Additional options for PCLINT
  PLOPTS += -max_threads=$(MAX_PROCESS) $(LINT_INC) $(LINT_SIZE)

# All of options for CCOPTS
  _C_CCOPTS := $(CCOPTS) $(C_CCOPTS)
  _X_CCOPTS := $(CCOPTS) $(X_CCOPTS)

ifeq ($(MAKELEVEL),0)
  ifneq ($(bypass),on)
    ifneq ($(words $(CCDEFS) UTEST_SUPPORT $(ASDEFS)), $(words $(sort $(CCDEFS) UTEST_SUPPORT) $(sort $(ASDEFS))))
      $(warning Some duplicate user definitions were detected)
      $(error Please check all -D flags in the compiler options [make bypass=on print.CCOPTS.ASOPTS])
    endif # $(CCDEFS) UTEST_SUPPORT $(ASDEFS)
  endif # bypass != on
endif # MAKELEVEL == 0

# Definitions for the code coverage feature
ifeq ($(RUN_CCOV), on)
  CCOV_CC += -fprofile-arcs -ftest-coverage
  CCOV_LD += -lgcov --coverage
endif # RUN_CCOV == on

# List of dependencies to re-compile and re-link
  LIST_CCD := $(strip $(_C_CCOPTS) $(CCOV_CC))
  LIST_CXD := $(strip $(_X_CCOPTS) $(CCOV_CC))
  LIST_ASD := $(strip $(ASOPTS))
  LIST_LDD := $(strip $(LDOPTS) $(CCOV_LD) $(OBJ_AVAIS))

# Config path for programming language
  CC_EXE := $(CC_PATH)/$(GCC_NAME).exe
  AS_EXE := $(CC_PATH)/$(GCC_NAME).exe
  PP_EXE := $(CC_PATH)/$(CPP_NAME).exe
  DB_EXE := $(CC_PATH)/$(GDB_NAME).exe
  LD_EXE := $(if $(filter %.cc %.cp %.cxx %.cpp %.c++ %.CPP %.C, $(ALL_SRC_FILES)), $(PP_EXE), $(CC_EXE))

# Config path for PCLINT
  PL_EXE := $(PL_PATH)/$(PCL_NAME).exe

#---------------------------------------------------------------------------------#
#                                     Export                                      #
#---------------------------------------------------------------------------------#

ifeq ($(MAKELEVEL),0)
  include $(TOOL_DIR)/make/export.mk

  USER_DEFS := $(sort $(CCDEFS) $(ASDEFS))
  USER_ENVS := $(sort $(USER_ENVS))
  EXPS := $(sort $(EXP) $(USER_ENVS) $(addprefix DEF_,$(USER_DEFS)))

  export $(EXPS)
endif # MAKELEVEL == 0

#---------------------------------------------------------------------------------#
#                                      Rules                                      #
#---------------------------------------------------------------------------------#

# All rules
  .PHONY: quick force rebuild setup info clean build run debug report show_report \
          analyze vsinit list move.% remove.% import.% export.% print.%

# Extension rules (Please do not use them directly)
  .PHONY: _build _s_build _check_depend _s_analyze

  BUILD_CHECK := $(OUT_DIR) _check_depend
  include $(TOOL_DIR)/make/rules.mk

#---------------------------------------------------------------------------------#
#                                   Dependencies                                  #
#---------------------------------------------------------------------------------#

ifneq ($(bypass),on)
  ifneq ($(filter _build %.o $(PROJ_EXE) analyze, $(MAKECMDGOALS)),)
    -include $(PROJ_EXE:%.exe=%.d)
    SRC_DEPS := $(addprefix $(OUT_DIR)/,$(notdir $(shell echo "$(filter-out $(ALL_SRC_FILES), $(SRC_PREV))" | sed 's/\.[^.]*\(\s\|$$\)/.\* /g')))
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
