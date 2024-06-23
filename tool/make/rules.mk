#=================================================================================#
# File         rules.mk                                                           #
# Author       Long Dao                                                           #
# About        https://louisvn.com                                                #
# Version      2.0.0                                                              #
# Release      07-01-2024                                                         #
# Details      C/C++ project management tool - [MK] Rules                         #
#=================================================================================#

#---------------------------------------------------------------------------------#
#                                      Rules                                      #
#---------------------------------------------------------------------------------#

.ONESHELL:

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
# Command: [make rebuild]
# Details: Clean the output and rebuild
#
rebuild: clean build

# =================================================================================
# Command: [make setup]
# Details: Initialize (or reinitialize) the Framework
#
setup:
	@dos2unix -q $(SHELL_DIR)/* $(TOOL_DIR)/extend/* make.sh makefile &
	@rm -rf $(TOOL_DIR)/tmp; mkdir -p $(TOOL_DIR)/tmp & $(MAKE) bypass=on vsinit

# =================================================================================
# Command: [make info]
# Details: Print on the screen some information about the project
#
# Command: [make clean]
# Details: Clean all files in project output and report files (if any)
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
# Command: [make show_report]
# Details: Displays the previously generated report file
#
# Command: [make vsinit]
# Details: Configure VSCode so that the software links to the correct path
#
info clean run debug report show_report vsinit:
	@$(SHELL) $(SHELL_DIR)/actions.sh $@

# =================================================================================
# Command: [make build]
# Details: Compile all source files in the project and link into an executable
#
build:
	@$(MAKE) _build -j$(MAX_PROCESS)

# ------------------------------- Expansion Targets -------------------------------

_build: _s_build $(PROJ_EXE)
	@$(if $(filter $(BUILD_VAL), 2), $(SHELL) $(SHELL_DIR)/actions.sh check_build; $(build_end)) $(eval BUILD_VAL := 0)

_s_build:
	@$(eval BUILD_VAL := 1)$(eval SH_SPACE := "")

_check_depend:
	@$(src_depend) & $(SHELL) $(SHELL_DIR)/actions.sh depend_update

$(PROJ_EXE): $(OBJ_FILES)
	@$(build_start) $(call message_green, Linking to $(PROJ_EXE)) & $(call build_cmd, $(LD_EXE) $(LDOPTS) $(CCOV_LD) $(OBJ_FILES) -o $@)

$(OUT_DIR):
	@$(build_start) $(call message_blue, Adding $@) & mkdir -p $@

# =================================================================================
# Command: [make <src_name>.o]
# Details: Compile the specific source file to the corresponding o file
#
$(OUT_DIR)/%.cc.o:  %.cc  | $(BUILD_CHECK) ; @$(call build_process, $(PP_EXE), CCOPTS)
$(OUT_DIR)/%.cp.o:  %.cp  | $(BUILD_CHECK) ; @$(call build_process, $(PP_EXE), CCOPTS)
$(OUT_DIR)/%.cxx.o: %.cxx | $(BUILD_CHECK) ; @$(call build_process, $(PP_EXE), CCOPTS)
$(OUT_DIR)/%.cpp.o: %.cpp | $(BUILD_CHECK) ; @$(call build_process, $(PP_EXE), CCOPTS)
$(OUT_DIR)/%.c++.o: %.c++ | $(BUILD_CHECK) ; @$(call build_process, $(PP_EXE), CCOPTS)
$(OUT_DIR)/%.CPP.o: %.CPP | $(BUILD_CHECK) ; @$(call build_process, $(PP_EXE), CCOPTS)
$(OUT_DIR)/%.C.o:   %.C   | $(BUILD_CHECK) ; @$(call build_process, $(PP_EXE), CCOPTS)
$(OUT_DIR)/%.c.o:   %.c   | $(BUILD_CHECK) ; @$(call build_process, $(CC_EXE), CCOPTS)
$(OUT_DIR)/%.s.o:   %.s   | $(BUILD_CHECK) ; @$(call build_process, $(AS_EXE), ASOPTS)
$(OUT_DIR)/%.S.o:   %.S   | $(BUILD_CHECK) ; @$(call build_process, $(AS_EXE), ASOPTS)

$(OBJ_NONAMES): %.o: ; @$(call message_green, [$@] Try targets that are similar but not vague. Such as: $(word 1, $(OBJ_NAMES))\n )
$(OBJ_NAMES): %.o: $(OUT_DIR)/%.o ; @:
$(OBJ_AVAIS): ; @:

# =================================================================================
# Command: [make analyze]
# Details: Perform static code analysis using PC-Lint
#
analyze: _s_analyze $(OUT_DIR) _check_depend $(LINT_C_H) $(LINT_CPP_H) $(LINT_INC) $(LINT_SIZE)

  ifneq ($(strip $(C_PCL_FILES)),)
	@$(call message_blue, Analyzing all C files ...) &
	@$(call build_cmd ,$(PL_EXE) -header\($(LINT_C_H)\) +libh\($(LINT_C_H)\) $(PLOPTS) $(C_PLOPTS) $(C_PCL_FILES) > $(ANALYZE_LOG))
  endif # C_PCL_FILES != <empty>

  ifneq ($(strip $(CPP_PCL_FILES)),)
	@$(call message_blue, Analyzing all C++ files ...) &
	@$(call build_cmd ,$(PL_EXE) -header\($(LINT_CPP_H)\) +libh\($(LINT_CPP_H)\) $(PLOPTS) $(X_PLOPTS) $(CPP_PCL_FILES) > $(ANALYZE_LOG))
  endif # CPP_PCL_FILES != <empty>

  ifneq ($(strip $(C_PCL_FILES) $(CPP_PCL_FILES)),)
	@if [ -f $(ANALYZE_LOG) ]; then $(call message_green, See report at: $(ANALYZE_LOG))
	@else $(call message_error, Error analysis! Please check the log file at: $(LOG_FILE)); fi; echo
  endif # (C_PCL_FILES|CPP_PCL_FILES) != <empty>

	@$(call process_end, analyze)

# ------------------------------- Expansion Targets -------------------------------

_s_analyze:
	@$(call process_start, analyze); echo

$(LINT_C_H):
	@$(call message_green, Generating $@) &
	@$(call build_cmd ,: > $@.c && $(CC_EXE) $(CCOPTS) -E -dM $@.c -o $@ && rm -f $@.c)

$(LINT_CPP_H):
	@$(call message_green, Generating $@) &
	@$(call build_cmd ,: > $@.cpp && $(PP_EXE) $(CCOPTS) -E -dM $@.cpp -o $@ && rm -f $@.cpp)

$(LINT_INC):
	@$(call message_green, Generating $@) &
	@$(call build_cmd ,: > $@.cpp && $(PP_EXE) $(CCOPTS) -v -c $@.cpp -o $@.o > $@.tmp 2>&1 && dos2unix $@.tmp &>/dev/null && \
	sed -n '/#include <...> search starts here:/$(COMMA)/End of search list./{//!{//!s/^[ \t]*//; s/.*/--i"&"\n+libdir\("&"\)/; p}}' $@.tmp > $@; \
	rm -f $@.*)

$(LINT_SIZE): $(TOOL_DIR)/extend/pclint_size.cpp
	@$(call message_green, Generating $@) &
	@$(call build_cmd ,$(PP_EXE) $(CCOPTS) $< -o $(PROJ_TMPEXE) && $(PROJ_TMPEXE) > $@; rm -f $(PROJ_TMPEXE))

# =================================================================================
# Command: [make list]
# Details: Print to the screen the names of files and folders in the project
#
list:
	@$(call process_start, list); echo; tree $(PROJ_DIR); echo; $(call process_end, list)

# =================================================================================
# Command: [make move.{project}]
# Details: Move to new project (automatically create if it doesn't exist)
#
$(filter move.%, $(MAKECMDGOALS)):
	@$(SHELL) $(SHELL_DIR)/actions.sh move $(call convert_path, move)

# =================================================================================
# Command: [make remove.{project}/{group}]
# Details: Remove an existing project or group
#
$(filter remove.%, $(MAKECMDGOALS)):
	@$(SHELL) $(SHELL_DIR)/actions.sh remove $(call convert_path, remove)

# =================================================================================
# Command: [make import.{name} zip=<path/to/zip>]
# Details: Import a shared project or group from any CMFramework
#
$(filter import.%, $(MAKECMDGOALS)):
	@$(SHELL) $(SHELL_DIR)/actions.sh import $(call convert_path, import) $(subst \,/,$(zip))

# =================================================================================
# Command: [make export.{project}/{group}]
# Details: Pack your project or group ready to share
#
$(filter export.%, $(MAKECMDGOALS)): | $(SHARE_DIR)
	@$(SHELL) $(SHELL_DIR)/actions.sh export $(call convert_path, export)

# ------------------------------- Expansion Targets -------------------------------

$(SHARE_DIR): ; @mkdir -p $@

# =================================================================================
# Command: [make print.<var1>.<var2>...]
# Details: Prints out the values ​​of the variable(s) used inside MAKE files
#
print.%:
	@$(call process_start, print)
	@$(ECHO) "$(foreach li,$(subst ., ,$(@:print.%=%)),\n$(li) =$(foreach ul,$($(li)),\n  $(strip $(subst ",\",$(subst \,\\,$(ul)))))\n)"
	@$(call process_end, print)

#---------------------------------------------------------------------------------#
#                                   End of file                                   #
#---------------------------------------------------------------------------------#
