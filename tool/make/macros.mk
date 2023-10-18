#=================================================================================#
# File         macros.mk                                                          #
# Author       Long Dao                                                           #
# About        https://louisvn.com                                                #
# Version      1.0.3                                                              #
# Update       10-04-2023                                                         #
# Copyright    2023 (c) Belongs to Louisvn                                        #
# Details      C/C++ project management tool - Macros                             #
#=================================================================================#

#---------------------------------------------------------------------------------#
#                                      Macros                                     #
#---------------------------------------------------------------------------------#

process_start  =  $(ECHO) "$(INVERT)<<< Start $(strip $(1)) $(RCOLOR)\n"

process_end    =  $(ECHO) "$(GRAY)$(INVERT)" && \
                  date +'>>> Finish $(strip $(1)) at '%H:%M:%S' on '%Y-%m-%d' ' && $(ECHO) "$(RCOLOR)"

message_error  =  $(ECHO) "$(RED)~ ERROR: $(strip $(1)) $(RCOLOR)"

message_red    =  $(ECHO) "$(RED)> $(RCOLOR)$(strip $(1))"

message_green  =  $(ECHO) "$(GREEN)> $(RCOLOR)$(strip $(1))"

message_blue   =  $(ECHO) "$(BLUE)> $(RCOLOR)$(strip $(1))"

build_check    =  $(if $(filter $(BUILD_VAL), 1), $(eval BUILD_VAL := 2) $(eval build_start := ) $(call process_start, build) & )
build_start    =  $(build_check)
build_end      =  $(call process_end, build) $(eval BUILD_VAL := 0) $(eval build_start = $(build_check))

build_cmd      =  (echo; echo $(strip $(1)); echo) >> $(LOG_FILE); \
                  log=$$($(1) 2>&1 || touch $(ERROR_FILE)); \
                  if ! [ -z "$$log" ]; then (echo WARN; echo "$$log"; echo) | tee -a $(LOG_FILE); fi

build_process  =  $(build_start) $(call message_green, Compiling from $<) & \
                  $(call build_cmd ,$(1) $(CCFLAGS) $(MASK_INC_DIRS) -MMD -MP -MF $(@:%.o=%.d) \
                  $(if $(filter $(notdir $<),$(SRC_NODEBUG_FILES)),,-g3) $(if $(filter $(dir $<),$(DEV_DIR)/),$(CCOV_CC)) $< -o $@)

build_status   =  $(call message_blue, Status: [$$([ -e $(ERROR_FILE) ] && \
                  ($(ECHO) "$(RED)FAIL$(RCOLOR)" & rm -f $(PROJ_EXE)) || \
                  $(ECHO) "$(GREEN)PASS$(RCOLOR)")] -> $(LOG_FILE))

curr_project   =  $(eval CURR_PROJ_NAME := $(1)) $(eval PROJ_DIR := $(BASE_DIR)/$(CURR_PROJ_NAME))

move_error     =  $(call message_error, [$(CURR_PROJ_NAME)] is a group of projects!)

move_proj      =  $(call message_green, Moving [$(PROJ_NAME)] -> [$(CURR_PROJ_NAME)]) && \
                  sed -i -e 's/^\s*PROJ_NAME\s*:*=.*$$/  PROJ_NAME := $(subst /,\/,$(CURR_PROJ_NAME))/g' $(ROOT_DIR)/makefile && \
                  $(MAKE) __forced=on vsinit

user_response  =  $(ECHO) -n "$(GREEN)<$(RCOLOR) $(strip $(1) [Y/n]:) " && read r && [[ $$r =~ (^[Yy]$$)|(^$$) ]]

create_proj    =  $(call user_response, The [$(CURR_PROJ_NAME)] project does not exist. Do you want to create it?) && \
                  $(call message_red, Cloning $(PROJ_DIR)) && \
                  mkdir -p $(PROJ_DIR) && rm -rf $(TEMP_DIR)/out && cp -Rf $(TEMP_DIR)/* $(PROJ_DIR)

remove_err1    =  $(call message_error, The [$(CURR_PROJ_NAME)] project/group does not exist)

remove_err2    =  $(call message_error, Cannot remove template [$(CURR_PROJ_NAME)] project)

remove_proj    =  $(call user_response, Do you agree to remove this project/group ($(CURR_PROJ_NAME))?) && \
                  $(call message_red, Removing $(PROJ_DIR)) && \
                  rm -r -f $(PROJ_DIR) && rmdir -p --ignore-fail-on-non-empty $(dir $(PROJ_DIR)) \
                  $(if $(filter $(CURR_PROJ_NAME)%, $(PROJ_NAME)), $(call curr_project, $(TEMP_NAME)) && $(move_proj))

import_err1    =  $(call message_error, ZIP file does not exist or incorrect format)

import_err2    =  $(call message_error, The [$(CURR_PROJ_NAME)] project/group already exist)

import_proj    =  $(call message_green, Importing into [$(CURR_PROJ_NAME)]) && \
                  mkdir -p $(PROJ_DIR) && unzip $(subst \,/,$(ZIP)) -d $(PROJ_DIR)

export_clean   =  for f in $$(find $(PROJ_DIR) -type d -name "$(notdir $(OUT_DIR))"); do \
                  $(call message_red, Removing $$f); rm -rf $$f; done

export_err     =  $(call message_error, The [$(CURR_PROJ_NAME)] project/group does not exist)

export_process =  $(eval EXPORT_FILE := $(SHARE_DIR)/__$(subst /,.,$(CURR_PROJ_NAME)).zip) \
                  $(call message_green, Compressing to $(EXPORT_FILE)); \
                  cd "$(PROJ_DIR)"; zip -r $(EXPORT_FILE) ./*

#---------------------------------------------------------------------------------#
#                                   End of file                                   #
#---------------------------------------------------------------------------------#
