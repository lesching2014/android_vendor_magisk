LOCAL_PATH := $(call my-dir)

# This makefile simply copies Magisk to $PRODUCT_OUT. The real magic lies in build/core/Make
# https://github.com/Geofferey/omni_android_build/commit/8fc7d8f3cd8e0c09418047264475abc652439bdd
# Normally one would not modify an itegral makefile to include things of this nature, 
# but it attempts to overwrite init with symlinks to /system/bin/init, so, no choice.

ifeq ($(BOARD_MAGISK_INIT),true)

include $(CLEAR_VARS)
LOCAL_MODULE       := magiskinit
LOCAL_MODULE_TAGS  := optional

ifndef $(MAGISK_VERSION)
MAGISK_VERSION := 21.1
endif

ifeq ($(TARGET_ARCH), arm)
$(shell unzip -p $(LOCAL_PATH)/Magisk-v$(MAGISK_VERSION).zip arm/magiskinit > $(PRODUCT_OUT)/magiskinit)
else ifeq ($(TARGET_ARCH), arm64)
$(shell unzip -p $(LOCAL_PATH)/Magisk-v$(MAGISK_VERSION).zip arm/magiskinit64 > $(PRODUCT_OUT)/magiskinit)
else ifeq ($(TARGET_ARCH), x86)
$(shell unzip -p $(LOCAL_PATH)/Magisk-v$(MAGISK_VERSION).zip x86/magiskinit > $(PRODUCT_OUT)/magiskinit)
else ifeq ($(TARGET_ARCH), x86_64)
$(shell unzip -p $(LOCAL_PATH)/Magisk-v$(MAGISK_VERSION).zip x86/magiskinit64 > $(PRODUCT_OUT)/magiskinit)
endif

endif

