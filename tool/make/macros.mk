#=================================================================================#
# File         macros.mk                                                          #
# Author       Long Dao                                                           #
# About        https://louisvn.com                                                #
# Version      1.0.6                                                              #
# Release      11-10-2023                                                         #
# Copyright    2023 (c) Belongs to Louisvn                                        #
# Details      C/C++ project management tool - [MK] Macros                        #
#=================================================================================#

#---------------------------------------------------------------------------------#
#                                      Macros                                     #
#---------------------------------------------------------------------------------#

process_start  =  $(ECHO) "$(INVERT)<<< Start $(strip $(1)) $(RCOLOR)"

process_end    =  $(ECHO) -n "$(GRAY)$(INVERT)"; \
                  date +'>>> Finish $(strip $(1)) at '%H:%M:%S' on '%Y-%m-%d' '; $(ECHO) "$(RCOLOR)"

message_error  =  $(ECHO) "$(RED)~ ERROR: $(strip $(1)) $(RCOLOR)"

message_green  =  $(ECHO) "$(GREEN)> $(RCOLOR)$(strip $(1))"

message_blue   =  $(ECHO) "$(BLUE)> $(RCOLOR)$(strip $(1))"

src_depend     =  if [ -e $(OUT_DIR) ]; then echo "SRC_PREV := $(subst ",\",$(SRC_FILES))" > $(PROJ_EXE:.exe=.d); fi

build_tmp      =  $(if $(filter $(BUILD_VAL), 1), $(eval BUILD_VAL := 2) $(eval build_start := ) $(call process_start, build); echo; )

build_start    =  $(build_tmp)

build_end      =  echo; $(call process_end, build) $(eval build_start = $(build_tmp))

build_cmd      =  (echo; echo "$(subst ",\",$(subst \,\\,$(subst \\,\\\,$(strip $(1)))))"; echo) >> $(LOG_FILE) & \
                  log=$$($(subst \\,\\\,$(1)) 2>&1 || touch $(ERROR_FILE)); \
                  if ! [ -z "$$log" ]; then (echo WARN; echo "$$log"; echo) | tee -a $(LOG_FILE); fi

build_process  =  $(build_start) $(call message_green, Compiling from $<) & \
                  $(call build_cmd ,$(1) -c $($(strip $(2))) $(MASK_INC_DIRS) -MMD -MP -MF $(@:%.o=%.d) \
                  $(if $(filter $(notdir $<),$(SRC_NODEBUG_FILES)),,-g) $(if $(filter CCOPTS>$(DEV_DIR)/%,$(2)>$(dir $<)),$(CCOV_CC)) $< -o $@)

build_status   =  $(call message_blue, Status: [$$([ -e $(ERROR_FILE) ] && ($(ECHO) "$(RED)FAIL$(RCOLOR)" & rm -f $(OUT_DIR)/*.exe $(OUT_DIR)/*.map) || \
                  $(ECHO) "$(GREEN)PASS$(RCOLOR)")] -> $(LOG_FILE))

convert_path   =  $(subst \,/,$(patsubst $(strip $(1)).%,%,$@))

#---------------------------------------------------------------------------------#
#                                   End of file                                   #
#---------------------------------------------------------------------------------#
