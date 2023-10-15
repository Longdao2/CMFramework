#=================================================================================#
# File         depend.mk                                                          #
# Author       Long Dao                                                           #
# About        https://louisvn.com                                                #
# Version      1.0.3                                                              #
# Update       10-04-2023                                                         #
# Copyright    2023 (c) Belongs to Louisvn                                        #
# Details      C/C++ project management tool - Dependencies                       #
#=================================================================================#

#---------------------------------------------------------------------------------#
#                                   Dependencies                                  #
#---------------------------------------------------------------------------------#

  CCD_CHECK := $(shell [ "$$(cat $(CCD_FILE) 2>/dev/null)" = "$$(echo "$(CCFLAGS)")" ] || echo 0 )
  LDD_CHECK := $(shell [ "$$(cat $(LDD_FILE) 2>/dev/null)" = "$$(echo "$(LDFLAGS)")" ] || echo 0 )

  LOG_CHECK := $(shell [ -e $(OUT_DIR) ] && $(log_start) && echo -n > $(STATUS_FILE) && echo 1 || echo 0)

ifeq ($(CCD_CHECK),0)
  SILENT := $(shell rm -f $(OUT_DIR)/*.o)
endif

ifeq ($(LDD_CHECK),0)
  SILENT := $(shell rm -f $(PROJ_OBJ))
endif

-include $(OBJ_FILES:%.o=%.d)

#---------------------------------------------------------------------------------#
#                                   End of file                                   #
#---------------------------------------------------------------------------------#
