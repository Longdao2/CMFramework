#=================================================================================#
# File         rules.mk                                                           #
# Author       Long Dao                                                           #
# About        https://louisvn.com                                                #
# Version      1.0.3                                                              #
# Update       10-04-2023                                                         #
# Copyright    2023 (c) Belongs to Louisvn                                        #
# Details      C/C++ project management tool - Rules                              #
#=================================================================================#

#---------------------------------------------------------------------------------#
#                                      Rules                                      #
#---------------------------------------------------------------------------------#

# =================================================================================
# Command: [make quick] - Default
# Details: 
#
quick: build run

# =================================================================================
# Command: [make force]
# Details: 
#
force: clean build run

# =================================================================================
# Command: [make setup]
# Details: Initialize tools that allow certain special features to work
#
setup: $(TLS_EXE_NAMES)
	@$(MAKE) __forced=on vsinit

$(TLS_EXE_NAMES): %.exe: %.o
	@$(CC) $< -o $(TOOL_DIR)/bin/$@

# =================================================================================
# Command: [make info]
# Details: Print on the screen some information about the project
#
info:
	@$(call process_start, info);                   \
	echo "Project Name : $(PROJ_NAME)";             \
	echo "User Name    : $(USER_NAME)";             \
	echo "Run Timeout  : $(RUN_TIMEOUT)";           \
	echo "Run CCOV     : $(RUN_CCOV)";              \
	echo "Show Report  : $(SHOW_REPORT)";           \
	echo "See More     : $(PROJ_DIR)/user_cfg.mk";  \
	$(call process_end, info)

# =================================================================================
# Command: [make clean]
# Details: Clean all files in project output
#
clean:
	@$(call clean_output, 1, $(OUT_DIR) $(REPORT_HTML) $(shell ls $(DOC_DIR)/$(PROJ_RAW)_ccov.* 2>/dev/null))
	@$(eval CCD_CHECK := 0) $(eval LDD_CHECK := 0)

# =================================================================================
# Command: [make build]
# Details: Compile all source files in project
#
build: _s_build $(OUT_DIR) $(OBJ_FILES) $(PROJ_OBJ) $(PROJ_EXE)
	@$(if $(filter 2,$(BUILD_VAL)), $(build_status); $(call process_end, build) $(eval BUILD_VAL := 0))

$(PROJ_OBJ): $(OBJ_FILES) | $(OUT_DIR) _check_depend
	@$(build_start) $(call message_blue, Merging to $@)
	@$(call build_cmd, $(LD) $(LDFLAGS) $(OBJ_FILES) -o $@)

$(PROJ_EXE): $(PROJ_OBJ) | $(OUT_DIR)
	@$(build_start) $(call message_blue, Linking to $(PROJ_EXE))
	@$(call build_cmd, $(LD) $< -o $(PROJ_EXE))

$(OUT_DIR):
	@$(build_start) $(call message_red, Adding $@) && mkdir -p $@

_s_build: | _check_project
	@$(eval BUILD_VAL := 1)

_check_project:
	@$(if $(filter $(PROJ_NAME),$(TEMP_NAME)), \
	$(error Some features are limited on template project. Please create or move to another project))

_check_depend:
	@$(if $(filter 0, $(CCD_CHECK)), $(eval CCD_CHECK := 1) $(build_start) echo "$(CCFLAGS)" > $(CCD_FILE))
	@$(if $(filter 0, $(LDD_CHECK)), $(eval LDD_CHECK := 1) $(build_start) echo "$(LDFLAGS)" > $(LDD_FILE))
	@$(if $(filter 0, $(LOG_CHECK)), $(eval LOG_CHECK := 1) $(log_satrt))

# =================================================================================
# Command: [make <src_name>.o]
# Details: Compile of a particular c/cpp/cc file to the corresponding o file
#
$(OUT_DIR)/%.o: %.c   | _check_project $(OUT_DIR) _check_depend ; @$(call build_process, $(CC))
$(OUT_DIR)/%.o: %.cpp | _check_project $(OUT_DIR) _check_depend ; @$(call build_process, $(PP))
$(OUT_DIR)/%.o: %.cc  | _check_project $(OUT_DIR) _check_depend ; @$(call build_process, $(PP))
$(OBJ_NAMES): %.o: $(OUT_DIR)/%.o | _check_project $(OUT_DIR) _check_depend ; @:

# =================================================================================
# Command: [make run]
# Details: Run the executable already in the project
#
run: | _check_project
	@$(call process_start, run)
	@[ -e $(PROJ_EXE) ] && ( $(run_process) ) || $(call message_error, [$(PROJ_EXE)] does not exist)
	@$(call process_end, run)

# =================================================================================
# Command: [make report]
# Details: Generate test report after running the program (use tptest.h)
#
report: | _check_project
	@if ! [ "$$(ls $(OUT_DIR)/*.{ret,gcno} 2>/dev/null)" = "" ]; then \
	$(call process_start, report); \
	$(call clean_output, 0, $(REPORT_HTML) $(shell ls $(DOC_DIR)/$(PROJ_RAW)_ccov.* 2>/dev/null)); \
	$(report_process); \
	$(call process_end, report); fi

# =================================================================================
# Command: [make vsinit]
# Details: Configure VSCode so that the software links to the correct path (only support GDB)
#
vsinit:
	@mkdir -p $(ROOT_DIR)/.vscode
	@$(TOOL_DIR)/bin/vsinit.exe '$(PROJ_EXE)' '$(STOP_AT_ENTRY)' '$(EXTERNAL_CONSOLE)' $(MASK_INC_DIRS) $(VAR_ARGS)

# =================================================================================
# Command: [make list]
# Details: Print to the screen the names of files and folders in the project
#
list:
	@$(call process_start, list); tree $(PROJ_DIR); $(call process_end, list)

# =================================================================================
# Command: [make move.{project}]
# Details: Move to new project (automatically create if it doesn't exist)
#
$(filter move.%, $(MAKECMDGOALS)):
	@$(call process_start, move) $(call curr_project, $(@:move.%=%))
	@$(if $(wildcard $(PROJ_DIR)), $(if $(wildcard $(PROJ_DIR)/user_cfg.mk), $(move_proj), $(move_error)), $(create_proj) && $(move_proj) || :;)
	@$(call process_end, move)

# =================================================================================
# Command: [make remove.{project}/{group}]
# Details: Remove an existing project/group
#
$(filter remove.%, $(MAKECMDGOALS)):
	@$(call process_start, remove) $(call curr_project, $(@:remove.%=%))
	@$(if $(wildcard $(PROJ_DIR)), $(if $(filter $(PROJ_DIR),$(TEMP_DIR)), $(remove_err2), $(remove_proj)) || :, $(remove_err1))
	@$(call process_end, remove)

# =================================================================================
# Command: [make import.{name} ZIP=<path/to/zip>]
# Details: Import a shared project/group from any CMFramework
#
$(filter import.%, $(MAKECMDGOALS)):
	@$(call process_start, import) $(call curr_project, $(@:import.%=%))
	@$(if $(filter $(words $(ZIP)),1), $(if $(filter %.zip, $(wildcard $(subst \,/,$(ZIP)))), \
	 $(if $(wildcard $(PROJ_DIR)), $(import_err2), $(import_proj)), $(import_err1)), $(import_err1))
	@$(call process_end, import)

# =================================================================================
# Command: [make export.{project}/{group}]
# Details: Pack your project/group ready to share
#
$(filter export.%, $(MAKECMDGOALS)): | $(SHARE_DIR)
	@$(call process_start, export) $(call curr_project, $(@:export.%=%))
	@$(if $(wildcard $(PROJ_DIR)), $(export_clean) && $(export_process), $(export_err))
	@$(call process_end, export)

$(SHARE_DIR):
	@$(call message_red, Adding $@) && mkdir -p $@

# =================================================================================
# Command: [make print.<var1>.<var2>...]
# Details: Print the data of any variable in this makefile > Debug
#
print.%:
	@$(call process_start, print)
	@$(ECHO) "$(foreach BASE,$(subst ., ,$(@:print.%=%)), \n$(BLUE)$(BASE) =$(RCOLOR) $(foreach SUB,$($(BASE)), \
	\n    $(strip $(subst ",\",$(subst \,\\,$(SUB)))))\n )"
	@$(call process_end, print)

#---------------------------------------------------------------------------------#
#                                   End of file                                   #
#---------------------------------------------------------------------------------#
