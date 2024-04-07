#=================================================================================#
# File         macros.mk                                                          #
# Author       Long Dao                                                           #
# About        https://louisvn.com                                                #
# Version      1.0.9                                                              #
# Release      04-10-2024                                                         #
# Details      C/C++ project management tool - [MK] Macros                        #
#=================================================================================#

#---------------------------------------------------------------------------------#
#                                      Macros                                     #
#---------------------------------------------------------------------------------#

process_start  =  $(ECHO) "$(REVERSE)<<< Start $(strip $(1)) $(RCOLOR)"

process_end    =  $(ECHO) -n "$(GRAY)$(REVERSE)"; \
                  date +'>>> Finish $(strip $(1)) at '%H:%M:%S' on '%Y-%m-%d' '; $(ECHO) "$(RCOLOR)"

usr_define     =  $(eval DEF := $(strip $(1)))-D$(DEF)$(if $(DEF_$(DEF)),="$(subst ",\",$(subst \,\\,$(DEF_$(DEF))))")

message_error  =  $(ECHO) "$(RED)~ ERROR: $(strip $(1)) $(RCOLOR)"

message_green  =  $(ECHO) "$(GREEN)> $(RCOLOR)$(strip $(1))"

message_blue   =  $(ECHO) "$(BLUE)> $(RCOLOR)$(strip $(1))"

src_depend     =  if [ -e $(OUT_DIR) ]; then echo "SRC_PREV := $(subst ",\",$(SRC_FILES))" > $(PROJ_EXE:.exe=.d); fi

build_tmp      =  $(if $(filter $(BUILD_VAL), 1), $(eval BUILD_VAL := 2) $(eval build_start := ) $(call process_start, build); echo; )

build_start    =  $(build_tmp)

build_end      =  echo; $(call process_end, build) $(eval build_start = $(build_tmp))

build_cmd      =  log=$$($(strip $(1)) 2>&1); command=$$(echo; echo "$(subst ",\",$(subst \,\\,$(strip $(1))))"; echo); \
                  if ! [ -z "$$log" ]; then (echo "$$command"; echo; echo INFO; echo "$$log"; echo) >> $(LOG_FILE); \
                  echo " "; echo "$$log"; echo " "; else echo "$$command" >> $(LOG_FILE); fi

build_process  =  $(build_start) echo "$$($(call message_green, Compiled $<) & \
                  $(call build_cmd ,$(1) -c $($(strip $(2))) $(MASK_INC_DIRS) -MMD -MP -MF $(@:%.o=%.d) \
                  $(if $(filter $(notdir $<),$(SRC_NODEBUG_FILES)),,-g) $(if $(filter CCOPTS>$(DEV_DIR)/%,$(2)>$<),$(CCOV_CC)) $< -o $@))"

convert_path   =  "$(subst \,/,$(patsubst $(strip $(1)).%,%,$@))"

#---------------------------------------------------------------------------------#
#                                   End of file                                   #
#---------------------------------------------------------------------------------#
