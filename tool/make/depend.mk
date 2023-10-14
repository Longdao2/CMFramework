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

  CC_DEPEND_FILE := $(OUT_DIR)/$(PROJ_RAW).ccd
  LD_DEPEND_FILE := $(OUT_DIR)/$(PROJ_RAW).ldd

  CC_DEPEND_CHECK := $(shell [ "$$(cat $(CC_DEPEND_FILE) 2>/dev/null)" = "$$(echo "$(CCFLAGS)")" ] || echo 0 )
  LD_DEPEND_CHECK := $(shell [ "$$(cat $(LD_DEPEND_FILE) 2>/dev/null)" = "$$(echo "$(LDFLAGS)")" ] || echo 0 )

  SILENT := $(shell [ -e $(OUT_DIR) ] && echo -n > $(LOG_FILE) && echo -n > $(STATUS_FILE))

ifeq ($(CC_DEPEND_CHECK),0)
  SILENT := $(shell rm -f $(OUT_DIR)/*.o)
endif

ifeq ($(LD_DEPEND_CHECK),0)
  SILENT := $(shell rm -f $(OUT_DIR)/$(PROJ_RAW).o)
endif

-include $(OBJ_FILES:%.o=%.d)

#---------------------------------------------------------------------------------#
#                                   End of file                                   #
#---------------------------------------------------------------------------------#
