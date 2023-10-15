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

clean_output   =  x=$(strip $(1)); $(foreach base, $(2), if [ -e $(base) ]; then if [ $$x = 1 ]; then \
                  $(call process_start, clean) && x=2; fi && \
                  $(call message_red, Removing $(base)) && rm -rf $(base); fi;) \
                  if [ $$x = 2 ]; then $(call process_end, clean); fi

build_cmd      =  ($(ECHO) "\nINFO" && echo "$(strip $(subst ",\",$(subst \,\\,$(1))))") >> $(LOG_FILE); \
                  ret=$$(($(1)) 2>&1 || echo -n 1 > $(STATUS_FILE)); \
                  if ! [ -z "$$ret" ]; then echo ---; echo "$$ret"; echo; ($(ECHO) "\nWARN"; echo "$$ret"; echo) >> $(LOG_FILE); fi

build_status   =  $(call message_blue, Status: [$$([ "$$(cat $(STATUS_FILE) 2>/dev/null)" = "1" ] && \
                  ($(ECHO) "$(RED)FAIL$(RCOLOR)" & rm -f $(PROJ_EXE)) || \
                  $(ECHO) "$(GREEN)PASS$(RCOLOR)")] -> $(LOG_FILE))

build_start    =  $(if $(filter 1, $(BUILD_VAL)), $(eval BUILD_VAL := 2) $(call process_start, build);)

build_process  =  $(build_start) $(call message_green, Compiling from $<); \
                  $(call build_cmd ,$(1) $(CCFLAGS) $(MASK_INC_DIRS) -MMD -MP -MF"$(@:%.o=%.d)" \
                  $(if $(filter $(notdir $<),$(SRC_NODEBUG_FILES)),,-g3) $(if $(filter $(dir $<),$(DEV_DIR)/),$(CCOV_CC)) $< -o $@)

run_process    =  check=0 && time_start=$$(date +%s%N) && \
                  timeout --kill-after=0s $(RUN_TIMEOUT) $(PROJ_EXE) $(VAR_ARGS) && retval=$$? || retval=$$?; \
                  time_end=$$(date +%s%N) && (( time_diff = (time_end - time_start) / 1000000 )) && \
                  [ $$retval = 124 ] && $(call message_error, $(RUN_TIMEOUT) timeout has expired) || check=1; \
                  [ -e "$(REPORT_RAW)" ] && $(ECHO) "0.duration = $$time_diff\n0.status = $$check" >> $(REPORT_RAW) || exit 0

report_process =  if [ -e $(REPORT_RAW) ]; then \
                  $(call message_green, Generating test report to $(REPORT_HTML)); $(report_gen1); \
                  $(call open_report,test,$(REPORT_HTML)); else $(report_gen2); fi

report_gen1    =  if [ "$(RUN_CCOV)" = "on" ]; then $(REPORT_EXE) $(REPORT_RAW) $(notdir $(CCOV_HTML)) $(REPORT_HTML); \
                  $(report_gen3); else $(REPORT_EXE) $(REPORT_RAW) "" $(REPORT_HTML); fi

report_gen2    =  if [ "$(RUN_CCOV)" = "on" ]; then $(report_gen3); $(call open_report,ccov,$(CCOV_HTML)); fi

report_gen3    =  $(call message_green, Generating ccov report to $(CCOV_HTML)) && \
                  $(GCOVR_EXE) --root $(DEV_DIR) --object-directory $(OUT_DIR) --html-details $(CCOV_HTML) || \
                  $(call message_error, Unable to generate CCOV report)

open_report    =  if [ -e "$(2)" ] && [ "$(SHOW_REPORT)" = "on" ]; then \
                  $(ECHO) "$(BLUE)> $(RCOLOR)Opening $(1) report in browser" && \
                  $(OPEN_URI_EXE) $(2) || $(call message_error, Cannot open $(2)); fi

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

export_process =  $(call message_green, Compressing to $(SHARE_DIR)/__$(subst /,.,$(CURR_PROJ_NAME)).zip) && \
                  cd "$(PROJ_DIR)" && zip -r $(SHARE_DIR)/__$(subst /,.,$(CURR_PROJ_NAME)).zip ./*

log_start      =  (echo; echo; date +'========================= '%H:%M:%S' '%Y-%m-%d' ========================='; echo) >> $(LOG_FILE)

#---------------------------------------------------------------------------------#
#                                   End of file                                   #
#---------------------------------------------------------------------------------#
