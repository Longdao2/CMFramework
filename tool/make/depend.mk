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

  CCD_FILE := $(OUT_DIR)/$(PROJ_RAW).ccd
  LDD_FILE := $(OUT_DIR)/$(PROJ_RAW).ldd

  CCD_CHECK := $(shell [ "$$(cat $(CCD_FILE) 2>/dev/null)" = "$$(echo "$(CCFLAGS)")" ] || echo 0 )
  LDD_CHECK := $(shell [ "$$(cat $(LDD_FILE) 2>/dev/null)" = "$$(echo "$(LDFLAGS)")" ] || echo 0 )

  SILENT := $(shell [ -e $(OUT_DIR) ] && echo -n > $(LOG_FILE) && echo -n > $(STATUS_FILE))

ifeq ($(CCD_CHECK),0)
  SILENT := $(shell rm -f $(OUT_DIR)/*.o)
endif

ifeq ($(LDD_CHECK),0)
  SILENT := $(shell rm -f $(OUT_DIR)/$(PROJ_RAW).o)
endif

-include $(OBJ_FILES:%.o=%.d)

#---------------------------------------------------------------------------------#
#                                   End of file                                   #
#---------------------------------------------------------------------------------#
