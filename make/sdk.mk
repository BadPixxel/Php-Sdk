
### ——————————————————————————————————————————————————————————————————
### —— Generic SDK Makefiles
### ——————————————————————————————————————————————————————————————————

ifndef VERBOSE
	MAKEFLAGS += --silent
endif

SELF_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

include $(SELF_DIR)/docker.mk
include $(SELF_DIR)/grumphp.mk
include $(SELF_DIR)/symfony.mk