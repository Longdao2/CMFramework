#=================================================================================#
# File         makefile                                                           #
# Author       Long Dao                                                           #
# About        https://louisvn.com                                                #
# Version      1.0.2                                                              #
# Update       16-09-2023                                                         #
# Copyright    2023 (c) Belongs to Louisvn                                        #
# Details      Common configuration for all projects                              #
#=================================================================================#

#---------------------------------------------------------------------------------#
#                                   Definitions                                   #
#---------------------------------------------------------------------------------#

# Path to your project (start at ALL_PROJ_DIR)
PROJ_NAME := ~temp

# Set bash as default console to run commands
SHELL = bash

# Used to perform an action with a recursive target
MAKE := make -s QUIET=on

# Define the colors to display on the console
ECHO      :=  echo -e
RED       :=  \033[0;31m
GREEN     :=  \033[0;32m
BLUE      :=  \033[0;34m
GRAY      :=  \033[38;2;97;97;97m
INVERT	  :=  \033[7m
RCOLOR    :=  \033[0m

ZIP :=
_S1  = "
_S2  = ,

# Base paths (start at Framework folder)
ROOT_DIR        := $(shell pwd | sed -e 's/\/cygdrive\/\(.\)/\1:/')
ALL_PROJ_DIR    := $(ROOT_DIR)/project
TOOL_DIR        := $(ROOT_DIR)/tool
SHARE_DIR       := $(ROOT_DIR)/share

TEMP_NAME       := ~temp
TEMP_DIR        := $(ALL_PROJ_DIR)/$(TEMP_NAME)
PROJ_DIR        := $(ALL_PROJ_DIR)/$(PROJ_NAME)
OUT_DIR         := $(PROJ_DIR)/out
DOC_DIR         := $(PROJ_DIR)/doc
PROJ_RAW_NAME   := $(notdir $(PROJ_NAME:%/=%))
MASK_PROJ_NAME  := PROJ_NAME

# Broken if the template project no longer exists
ifeq ("$(wildcard $(TEMP_DIR)/user_cfg.mk)","")
$(error Serious! Template project no longer exists, this framework is broken)
endif

# If the project directory is empty, should be "./path/to/project"
ifeq ("$(wildcard $(PROJ_DIR)/user_cfg.mk)","")
NOTHING := $(shell $(MAKE) PROJ_NAME=$(TEMP_NAME) move.$(TEMP_NAME))
$(error Project [$(PROJ_NAME)] has ceased to exist. So it was brought back to the template project)
endif

include $(PROJ_DIR)/user_cfg.mk

ifneq ($(SHOW_CMD),on)
SC = @
endif # SHOW_CMD != on

# Display informations
ifneq ($(QUIET),on)
$(info )
$(info PROJ > $(PROJ_NAME))
$(info DATE > $(shell date +%Y-%m-%d' '%H:%M:%S))
$(info USER > $(USER_NAME))
$(info )
endif # QUIET != on

# Path to test report files
REPORT_RAW      := $(OUT_DIR)/$(PROJ_RAW_NAME).ret
REPORT_HTML     := $(DOC_DIR)/$(PROJ_RAW_NAME).html
CCOV_HTML       := $(DOC_DIR)/$(PROJ_RAW_NAME)_ccov.html

.PHONY: setup all clean build run merge report status pack vsinit check \
        move.% remove.% import.% list print.%

all: clean build run

#---------------------------------------------------------------------------------#
#                                      Macro                                      #
#---------------------------------------------------------------------------------#

mac_start_process = $(ECHO) "$(INVERT)<<< Start $(1) $(RCOLOR)\n"
mac_end_process   = $(ECHO) "$(GRAY)$(INVERT)" && \
                    date +'>>> Finish $(1) at '%H:%M:%S' on '%Y-%m-%d' ' && $(ECHO) "$(RCOLOR)"

mac_vscode_init   = $(MAKE) vsinit

mac_create_proj   = echo "+ [$(LOCAL_PROJ_NAME)]" && \
                    mkdir -p $(PROJ_DIR) && \
                    rm -r -f $(TEMP_DIR)/out && \
                    rm -r -f $(TEMP_DIR)/doc/* && \
                    cp -Rf $(TEMP_DIR)/* $(PROJ_DIR)

mac_move_proj     = echo "~ [$(PROJ_NAME)] -> [$(LOCAL_PROJ_NAME)]" && \
                    sed -i -e 's/^ *$(MASK_PROJ_NAME) *:*=.*$$/$(MASK_PROJ_NAME) := $(subst /,\/,$(LOCAL_PROJ_NAME))/g' $(ROOT_DIR)/makefile && \
                    $(mac_vscode_init)

mac_remove_proj   = echo "- [$(LOCAL_PROJ_NAME)]" && \
                    rm -r -f $(PROJ_DIR) && \
                    rmdir -p --ignore-fail-on-non-empty $(dir $(PROJ_DIR:%/=%))

mac_import_proj   = echo "+ [$(LOCAL_PROJ_NAME)]" && \
                    mkdir -p $(PROJ_DIR) && \
                    unzip $(subst \,/,$(ZIP)) -d $(PROJ_DIR)

mac_move_error    = echo "x [$(LOCAL_PROJ_NAME)]"
mac_remove_err    = echo "i [$(TEMP_NAME)]"
mac_import_err    = echo "ZIP file does not exist"

define mac_build_process
	$(eval CCOVOPTS := $(if $(filter $(dir $<),$(DEV_DIR)/),$(CCOV_CC)))
	$(SC)$(ECHO) "$(GREEN)> $(RCOLOR)Compiling from $<"
	$(SC)$(CC) $(CCFLAGS) $(if $(filter $(notdir $<),$(SRC_NODEBUG_FILES)),,-g3) $(CCOVOPTS) $< -o $(OUT_DIR)/$@
endef

#---------------------------------------------------------------------------------#
#                                     Process                                     #
#---------------------------------------------------------------------------------#

# Check input parameters are valid
ifneq ($(filter move.%,$(MAKECMDGOALS))$(filter remove.%,$(MAKECMDGOALS))$(filter import.%,$(MAKECMDGOALS)),)
ifneq ($(words $(MAKECMDGOALS)),1)
$(error You can only use the command [move], [remove] or [import] individually)
endif #
endif #

# Config for each programming language
ifeq ($(USE_CPP),on)
CC := g++
else # USE_CPP != on
CC := gcc
endif # USE_CPP == on

# Search all source files in the project
SRC_FILES +=  $(foreach SRC_DIRS,$(SRC_DIRS),$(wildcard $(SRC_DIRS)/*.c))
ifeq ($(USE_CPP),on)
SRC_FILES +=  $(foreach SRC_DIRS,$(SRC_DIRS),$(wildcard $(SRC_DIRS)/*.cpp)) \
              $(foreach SRC_DIRS,$(SRC_DIRS),$(wildcard $(SRC_DIRS)/*.cc))
endif # USE_CPP == on
OBJ_FILES :=  $(foreach SRC_DIRS,$(SRC_DIRS),$(wildcard $(SRC_DIRS)/*.o))

# List of source code files that do not support debugging
SRC_NODEBUG_FILES += utest.c

# Search all object files in the tool
TLS_OBJ_FILES := $(wildcard $(TOOL_DIR)/bin/obj/*.o)
TLS_EXE_NAMES := $(notdir $(TLS_OBJ_FILES:%.o=%.exe))

vpath %.c $(dir $(SRC_FILES))
ifeq ($(USE_CPP),on)
vpath %.cpp $(dir $(SRC_FILES))
vpath %.cc $(dir $(SRC_FILES))
endif # USE_CPP == on
vpath %.o $(dir $(OBJ_FILES))
vpath %.o $(TOOL_DIR)/bin/obj

# Parsing file names in the project
OBJ_NAMES := $(notdir $(SRC_FILES:%.c=%.o))
ifeq ($(USE_CPP),on)
OBJ_NAMES := $(notdir $(OBJ_NAMES:%.cpp=%.o))
OBJ_NAMES := $(notdir $(OBJ_NAMES:%.cc=%.o))
endif # USE_CPP == on
OBJ_FILES += $(addprefix $(OUT_DIR)/,$(OBJ_NAMES))
OBJ_NAMES := $(notdir $(OBJ_FILES))

# Add prefix to the directory containing the header file
MASK_INC_DIRS := $(addprefix -I ,$(INC_DIRS))

# Definitions for testing
USER_DEFS   +=  -D UTEST_SUPPORT \
                -D "OUTPATH=\"$(REPORT_RAW)\"" \
                -D "USER_NAME=\"$(USER_NAME)\"" \
                -D "PROJ_NAME=\"$(PROJ_NAME)\""

# Add compiler flags (if any)
CCFLAGS += -c -Wall $(MASK_INC_DIRS) $(USER_DEFS)
LDFLAGS += -r

ifeq ($(RUN_CCOV), on)
CCOV_CC += -fprofile-arcs -ftest-coverage
CCOV_LD += --coverage
endif # RUN_CCOV == on

#---------------------------------------------------------------------------------#
#                                      Rules                                      #
#---------------------------------------------------------------------------------#

# =================================================================================
# Command: [make setup]
# Details: Initialize tools that allow certain special features to work
#
setup: $(TLS_EXE_NAMES)
	$(SC)$(MAKE) vsinit

$(TLS_EXE_NAMES): %.exe: %.o
	$(SC)gcc $< -o $(TOOL_DIR)/bin/$@

# =================================================================================
# Command: [make clean]
# Details: Clean all files in project output
#
clean:
	$(SC)$(call mac_start_process,clean)
	$(SC)$(ECHO) "$(RED)> $(RCOLOR)Removing $(OUT_DIR)" && rm -r -f $(OUT_DIR)
	$(SC)$(foreach base,$(wildcard $(REPORT_HTML) $(DOC_DIR)/$(PROJ_RAW_NAME)_ccov.*),\
	$(ECHO) "$(RED)> $(RCOLOR)Removing $(base)" && rm -f $(base);)
	$(SC)$(call mac_end_process,clean)

# =================================================================================
# Command: [make build]
# Details: Compile all source files in project
#
build: _s_build $(OUT_DIR) $(OBJ_NAMES)
	$(SC)$(ECHO) "$(BLUE)> $(RCOLOR)Linking to $(OUT_DIR)/$(PROJ_RAW_NAME).exe"
	$(SC)$(CC) $(CCOV_LD) $(OBJ_FILES) -o $(OUT_DIR)/$(PROJ_RAW_NAME).exe
	$(SC)$(call mac_end_process,build)

_s_build: check
	$(SC)$(call mac_start_process,build)

$(SHARE_DIR) $(OUT_DIR):
	$(SC)$(ECHO) "$(RED)> $(RCOLOR)Adding $@"
	$(SC)mkdir -p $@

# =================================================================================
# Command: [make merge]
# Details: Compile all source files [.c .o] into a single object file
#
merge: _s_merge $(OUT_DIR) $(OBJ_NAMES)
	$(SC)$(ECHO) "$(BLUE)> $(RCOLOR)Merging to $(OUT_DIR)/$(PROJ_RAW_NAME).o"
	$(SC)$(CC) $(LDFLAGS) $(OBJ_FILES) -o $(OUT_DIR)/$(PROJ_RAW_NAME).o
	$(SC)$(call mac_end_process,merge)

_s_merge: check
	$(SC)$(call mac_start_process,merge)

# =================================================================================
# Command: [make <c_file_name>.o]
# Details: Compile of a particular c/cpp file to the corresponding o file
#
%.o: %.c check $(OUT_DIR)   ; $(call mac_build_process)
%.o: %.cpp check $(OUT_DIR) ; $(call mac_build_process)
%.o: %.cc check $(OUT_DIR)  ; $(call mac_build_process)

# =================================================================================
# Command: [make run]
# Details: Run the executable already in the project
#
run: check
	$(SC)$(call mac_start_process,run)
	$(SC)check=0 && time_start=$$(date +%s%N) && \
	timeout --kill-after=$(RUN_TIMEOUT) $(RUN_TIMEOUT) $(OUT_DIR)/$(PROJ_RAW_NAME).exe $(VAR_ARGS) && retval=$$? || retval=$$?; \
	time_end=$$(date +%s%N) && time_diff=$$(echo "(($$time_end - $$time_start) / 1000000)" | bc) && \
	[ $$retval -eq 124 ] && $(ECHO) "\n$(RED)> $(RUN_TIMEOUT) timeout has expired$(RCOLOR)" || check=1; \
	test -e "$(REPORT_RAW)" && $(ECHO) "0.duration = $$time_diff\n0.status = $$check" >> $(REPORT_RAW) || exit 0
	$(SC)$(call mac_end_process,run)

# =================================================================================
# Command: [make report]
# Details: Generate test report after running the program (use tptest.h)
#
report: check
	$(SC)$(call mac_start_process,report)
	$(SC)$(ECHO) "$(GREEN)> $(RCOLOR)Generating test report to $(REPORT_HTML)"
ifneq ($(RUN_CCOV), on)
	$(SC)$(TOOL_DIR)/bin/report.exe $(REPORT_RAW) "" $(REPORT_HTML)
else # RUN_CCOV == on
	$(SC)$(TOOL_DIR)/bin/report.exe $(REPORT_RAW) $(notdir $(CCOV_HTML)) $(REPORT_HTML)
	$(SC)$(ECHO) "$(GREEN)> $(RCOLOR)Generating ccov report to $(CCOV_HTML)"
	$(SC)gcovr --root $(DEV_DIR) --object-directory $(OUT_DIR) --html-details $(CCOV_HTML)
endif # RUN_CCOV != on
	$(SC)$(ECHO) "$(BLUE)> $(RCOLOR)Opening test report in browser"
	$(SC)cygstart $(REPORT_HTML) || xdg-open $(REPORT_HTML)
	$(SC)$(call mac_end_process,report)

# =================================================================================
# Command: [make pack]
# Details: Pack your project ready to share
#
pack: clean _s_pack $(SHARE_DIR)
	$(SC)$(ECHO) "$(GREEN)> $(RCOLOR)Compressing to $(SHARE_DIR)/$(PROJ_RAW_NAME).zip"
	$(SC)cd "$(PROJ_DIR)" && zip -r $(SHARE_DIR)/$(PROJ_RAW_NAME).zip ./*
	$(SC)$(call mac_end_process,pack)

_s_pack:
	$(SC)$(call mac_start_process,pack)

# =================================================================================
# Command: [make vsinit]
# Details: Configure VSCode so that the software links to the correct path (only support GDB)
#
vsinit:
	$(SC)mkdir -p $(ROOT_DIR)/.vscode
	$(SC)$(TOOL_DIR)/bin/vsinit.exe '$(OUT_DIR)/$(PROJ_RAW_NAME).exe' '$(STOP_AT_ENTRY)' '$(EXTERNAL_CONSOLE)' $(MASK_INC_DIRS) $(VAR_ARGS)

# =================================================================================
# Command: [make move.(<group>:)<project>]
# Details: Move to new project (automatically add if it doesn't exist)
# Reports: + [p] : Adding new project
#          x [p] : Cannot be removed because the path is a group
#          ~ [p] -> [p1] : Moving from [p] to [p1]
#
move.%:
	$(SC)$(call mac_start_process,move)
	$(eval LOCAL_PROJ_NAME := $(subst :,/,$(@:move.%=%)))
	$(eval PROJ_DIR := $(ALL_PROJ_DIR)/$(LOCAL_PROJ_NAME))
	$(SC)$(if $(wildcard $(PROJ_DIR)), \
		$(if $(wildcard $(PROJ_DIR)/user_cfg.mk), $(mac_move_proj), $(mac_move_error)), \
		$(mac_create_proj) && $(mac_move_proj) \
	)
	$(SC)$(call mac_end_process,move)

# =================================================================================
# Command: [make remove.(<group>:)<project>]
# Details: Remove an existing project
# Reports: - [p] : Removing project
#          i [p] : Cannot remove template project
#          x [p] : Cannot be removed because the path is a group
#          ? [p] : Project does not exist
#          ~ [p] -> [temp] : Moving from [p] to [temp]
#
remove.%:
	$(SC)$(call mac_start_process,remove)
	$(eval LOCAL_PROJ_NAME := $(subst :,/,$(@:remove.%=%)))
	$(eval PROJ_DIR := $(ALL_PROJ_DIR)/$(LOCAL_PROJ_NAME))
	$(SC)$(if $(filter $(PROJ_DIR),$(TEMP_DIR)), $(mac_remove_err), \
		$(if $(wildcard $(PROJ_DIR)), \
			$(if $(wildcard $(PROJ_DIR)/user_cfg.mk), \
				$(mac_remove_proj) $(if $(filter $(PROJ_NAME),$(LOCAL_PROJ_NAME)), $(eval LOCAL_PROJ_NAME := $(TEMP_NAME)) && $(mac_move_proj)), \
				$(mac_move_error) \
			), \
			echo "? [$(LOCAL_PROJ_NAME)]" \
		) \
	)
	$(SC)$(call mac_end_process,remove)

# =================================================================================
# Command: [make import.(<group>:)<name> ZIP=<path/to/zip>]
# Details: Import a shared project from any CMFramework
# Reports: + [p] : Adding new project
#          x [p] : Cannot be removed because the project already exists or the path is a group
#
import.%:
	$(SC)$(call mac_start_process,import)
	$(eval LOCAL_PROJ_NAME := $(subst :,/,$(@:import.%=%)))
	$(eval PROJ_DIR := $(ALL_PROJ_DIR)/$(LOCAL_PROJ_NAME))
	$(SC)$(if $(filter $(words $(ZIP)),1), \
		$(if $(filter %.zip,$(wildcard $(subst \,/,$(ZIP)))), \
			$(if $(wildcard $(PROJ_DIR)), \
				$(mac_move_error), \
				$(mac_import_proj) \
			), \
			$(mac_import_err) \
		), \
		$(mac_import_err) \
	)
	$(SC)$(call mac_end_process,import)

# =================================================================================
# Command: [make list]
# Details: Print to the screen the names of files and folders in the project
#
list:
	$(SC)$(call mac_start_process,list)
	$(SC)tree $(PROJ_DIR)
	$(SC)$(call mac_end_process,list)

# =================================================================================
# Command: [make print.<var1>.<var2>...]
# Details: Print the data of any variable in this makefile > Debug
#
print.%:
	$(SC)$(call mac_start_process,print)
	$(SC)$(ECHO) \
	"$(foreach BASE,$(subst ., ,$(@:print.%=%)), \
		\n$(BLUE)$(BASE) =$(RCOLOR) \
		$(foreach SUB,$($(BASE)),\n    $(SUB))\n \
	)"
	$(SC)$(call mac_end_process,print)

check:
	$(if $(filter $(PROJ_NAME),$(TEMP_NAME)), \
	$(error Some features are limited on template project. Please create or move to another project))
	@:

#---------------------------------------------------------------------------------#
#                                   End of file                                   #
#---------------------------------------------------------------------------------#
