#=================================================================================#
# File         macros.mk                                                          #
# Author       Long Dao                                                           #
# About        https://louisvn.com                                                #
# Version      1.0.5                                                              #
# Release      10-30-2023                                                         #
# Copyright    2023 (c) Belongs to Louisvn                                        #
# Details      C/C++ project management tool - [MK] Macros                        #
#=================================================================================#

#---------------------------------------------------------------------------------#
#                                      Macros                                     #
#---------------------------------------------------------------------------------#

process_start  =  $(ECHO) "$(INVERT)<<< Start $(strip $(1)) $(RCOLOR)\n"

process_end    =  $(ECHO) "$(GRAY)$(INVERT)"; \
                  date +'>>> Finish $(strip $(1)) at '%H:%M:%S' on '%Y-%m-%d' '; $(ECHO) "$(RCOLOR)"

message_error  =  $(ECHO) "$(RED)~ ERROR: $(strip $(1)) $(RCOLOR)"

message_green  =  $(ECHO) "$(GREEN)> $(RCOLOR)$(strip $(1))"

message_blue   =  $(ECHO) "$(BLUE)> $(RCOLOR)$(strip $(1))"

src_depend     =  if [ -e $(OUT_DIR) ]; then echo "SRC_PREV := $(subst ",\",$(SRC_FILES))" > $(PROJ_OBJ:%.o=%.d); fi

build_tmp      =  $(if $(filter $(BUILD_VAL), 1), $(eval BUILD_VAL := 2) $(eval build_start := ) $(call process_start, build) & )

build_start    =  $(build_tmp)

build_end      =  $(call process_end, build) $(eval build_start = $(build_tmp))

build_cmd      =  (echo; echo $(strip $(1)); echo) >> $(LOG_FILE) & \
                  log=$$($(1) 2>&1 || touch $(ERROR_FILE)); \
                  if ! [ -z "$$log" ]; then (echo WARN; echo "$$log"; echo) | tee -a $(LOG_FILE) & fi

build_process  =  $(build_start) $(call message_green, Compiling from $<) & \
                  $(call build_cmd ,$(1) $(CCFLAGS) $(MASK_INC_DIRS) -MMD -MP -MF $(@:%.o=%.d) \
                  $(if $(filter $(notdir $<),$(SRC_NODEBUG_FILES)),,-g3) $(if $(filter $(DEV_DIR)/%,$(dir $<)),$(CCOV_CC)) $< -o $@)

build_status   =  $(call message_blue, Status: [$$([ -e $(ERROR_FILE) ] && ($(ECHO) "$(RED)FAIL$(RCOLOR)" & rm -f $(PROJ_EXE)) || \
                  $(ECHO) "$(GREEN)PASS$(RCOLOR)")] -> $(LOG_FILE))

convert_path   =  $(subst \,/,$(patsubst $(strip $(1)).%,%,$@))

#---------------------------------------------------------------------------------#
#                                   End of file                                   #
#---------------------------------------------------------------------------------#
