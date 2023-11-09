#=================================================================================#
# File         rules.mk                                                           #
# Author       Long Dao                                                           #
# About        https://louisvn.com                                                #
# Version      1.0.6                                                              #
# Release      11-10-2023                                                         #
# Copyright    2023 (c) Belongs to Louisvn                                        #
# Details      C/C++ project management tool - [MK] Rules                         #
#=================================================================================#

#---------------------------------------------------------------------------------#
#                                      Rules                                      #
#---------------------------------------------------------------------------------#

# =================================================================================
# Command: [make quick] - Default
# Details: Build quickly and run the executable file
#
quick: build run

# =================================================================================
# Command: [make force]
# Details: Clean the output, rebuild, and run the executable file
#
force: clean build run

# =================================================================================
# Command: [make setup]
# Details: Initialize (or reinitialize) the Framework
#
setup:
	@dos2unix -q $(SHELL_DIR)/* $(TOOL_DIR)/extend/* make.sh makefile & \
	rm -rf $(SHELL_DIR)/tmp; mkdir -p $(SHELL_DIR)/tmp & $(MAKE) __forced=on vsinit

# =================================================================================
# Command: [make info]
# Details: Print on the screen some information about the project
#
info:
	@$(call process_start, info);                  \
	echo "Project Name : $(PROJ_NAME)";            \
	echo "User Name    : $(USER_NAME)";            \
	echo "Run Timeout  : $(RUN_TIMEOUT)";          \
	echo "Run CCOV     : $(RUN_CCOV)";             \
	echo "Show Report  : $(SHOW_REPORT)";          \
	echo "See More     : $(PROJ_DIR)/user_cfg.mk"; \
	$(call process_end, info)

# =================================================================================
# Command: [make clean]
# Details: Clean all files in project output
#
# Command: [make run]
# Details: Run the executable already in the project
#
# Command: [make debug]
# Details: Debug the executable already in the project using GDB
#
# Command: [make report]
# Details: Generate test report after running the program
#
# Command: [make vsinit]
# Details: Configure VSCode so that the software links to the correct path
#
clean run debug report vsinit:
	@$(SHELL_DIR)/actions.sh $@

# =================================================================================
# Command: [make build]
# Details: Compile all source files in the project and link into an executable
#
build: _s_build $(PROJ_EXE)
	@$(if $(filter $(BUILD_VAL), 2), $(build_status); $(build_end)) $(eval BUILD_VAL := 0)

$(PROJ_EXE): $(OBJ_FILES) | $(BUILD_CHECK)
	@$(build_start) $(call message_blue, Linking to $(PROJ_EXE)) & \
	$(call build_cmd, $(LD_EXE) $(LDOPTS) $(CCOV_LD) $(OBJ_FILES) -o $@)

$(OUT_DIR):
	@$(build_start) $(call message_blue, Adding $@) & mkdir -p $@

_s_build:
	@$(eval BUILD_VAL := 1)

_check_project:
	@$(if $(filter $(PROJ_NAME),$(TEMP_NAME)), $(error Some features are limited on template project. Please create or move to another project))

_check_depend:
	@rm -f $(ERROR_FILE) & $(src_depend) & $(SHELL_DIR)/actions.sh depend_update

# =================================================================================
# Command: [make <src_name>.o]
# Details: Compile the specific c/cpp/cc file to the corresponding o file
#
$(OUT_DIR)/%.c.o: %.c     | $(BUILD_CHECK) ; @$(call build_process, $(CC_EXE), CCOPTS)
$(OUT_DIR)/%.C.o: %.C     | $(BUILD_CHECK) ; @$(call build_process, $(PP_EXE), CCOPTS)
$(OUT_DIR)/%.s.o: %.s     | $(BUILD_CHECK) ; @$(call build_process, $(AS_EXE), ASOPTS)
$(OUT_DIR)/%.S.o: %.S     | $(BUILD_CHECK) ; @$(call build_process, $(AS_EXE), ASOPTS)
$(OUT_DIR)/%.cc.o: %.cc   | $(BUILD_CHECK) ; @$(call build_process, $(PP_EXE), CCOPTS)
$(OUT_DIR)/%.cpp.o: %.cpp | $(BUILD_CHECK) ; @$(call build_process, $(PP_EXE), CCOPTS)

$(OBJ_NAMES): %.o: $(OUT_DIR)/%.o ; @:
$(OBJ_AVAIL): ; @:

# =================================================================================
# Command: [make list]
# Details: Print to the screen the names of files and folders in the project
#
list:
	@$(call process_start, list) & tree $(PROJ_DIR); $(call process_end, list)

# =================================================================================
# Command: [make move.{project}]
# Details: Move to new project (automatically create if it doesn't exist)
#
$(filter move.%, $(MAKECMDGOALS)):
	@$(SHELL_DIR)/actions.sh move $(call convert_path, move)

# =================================================================================
# Command: [make remove.{project}/{group}]
# Details: Remove an existing project or group
#
$(filter remove.%, $(MAKECMDGOALS)):
	@$(SHELL_DIR)/actions.sh remove $(call convert_path, remove)

# =================================================================================
# Command: [make import.{name} zip=<path/to/zip>
# Details: Import a shared project or group from any CMFramework
#
$(filter import.%, $(MAKECMDGOALS)):
	@$(SHELL_DIR)/actions.sh import $(call convert_path, import) $(subst \,/,$(zip))

# =================================================================================
# Command: [make export.{project}/{group}]
# Details: Pack your project or group ready to share
#
$(filter export.%, $(MAKECMDGOALS)): | $(SHARE_DIR)
	@$(SHELL_DIR)/actions.sh export $(call convert_path, export)

$(SHARE_DIR): ; @mkdir -p $@

# =================================================================================
# Command: [make print.<var1>.<var2>...]
# Details: Print the data of any variable in this makefile > Debug
#
print.%:
	@$(call process_start, print); \
	$(ECHO) "$(foreach BASE,$(subst ., ,$(@:print.%=%)), \n$(BLUE)$(BASE) =$(RCOLOR) $(foreach SUB,$($(BASE)), \
	\n    $(strip $(subst ",\",$(subst \,\\,$(SUB)))))\n )"; \
	$(call process_end, print)

#---------------------------------------------------------------------------------#
#                                   End of file                                   #
#---------------------------------------------------------------------------------#
