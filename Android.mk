LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := 99-magisk
LOCAL_MODULE_SUFFIX := .sh
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_SRC_FILES := addon.d.sh
LOCAL_MODULE_PATH := $(TARGET_OUT)/addon.d

ifndef $(MAGISK_VERSION)
  MAGISK_VERSION := 26.1
endif

MY_MAGISK_MAJOR := $(shell echo $(MAGISK_VERSION) | cut -f1 -d.)

MY_MAGISK_INTERMEDIATES := $(TARGET_OUT_INTERMEDIATES)/$(LOCAL_MODULE_CLASS)/$(LOCAL_MODULE)_intermediates
MY_MAGISK_ARCHIVE := $(LOCAL_PATH)/Magisk-v$(MAGISK_VERSION).apk
MY_MAGISK_SIGNING_KEY := build/make/target/product/security/verity
MY_MAGISK_SIGNING_ARGS := --prop com.android.build.boot.os_version:$(PLATFORM_VERSION)

MY_MAGISK_SOURCE_IMAGE := $(MY_MAGISK_INTERMEDIATES)/new-boot.img
MY_MAGISK_SOURCE_ADDON := assets/addon.d.sh
MY_MAGISK_SOURCE_PATCH := assets/boot_patch.sh
MY_MAGISK_SOURCE_FUNCTIONS := assets/util_functions.sh
MY_MAGISK_SOURCE_STUB := assets/stub.apk

ifneq ($(filter arm arm64 ,$(TARGET_ARCH)),)
  MY_MAGISK_SOURCE_PATH_32 := lib/armeabi-v7a/
  ifeq ($(shell test $(MY_MAGISK_MAJOR) -gt 23; echo $$?),0)
    MY_MAGISK_SOURCE_PATH_64 := lib/arm64-v8a/
  else
    MY_MAGISK_SOURCE_PATH_64 := $(MY_MAGISK_SOURCE_PATH_32)
  endif
else ifneq ($(filter x86 x86_64 ,$(TARGET_ARCH)),)
  MY_MAGISK_SOURCE_PATH_32 := lib/x86/
  ifeq ($(shell test $(MY_MAGISK_MAJOR) -gt 23; echo $$?),0)
    MY_MAGISK_SOURCE_PATH_64 := lib/x86_64/
  else
    MY_MAGISK_SOURCE_PATH_64 := $(MY_MAGISK_SOURCE_PATH_32)
  endif
endif
ifneq ($(filter arm x86 ,$(TARGET_ARCH)),)
  MY_MAGISK_SOURCE_PATH := $(MY_MAGISK_SOURCE_PATH_32)
else ifneq ($(filter arm64 x86_64 ,$(TARGET_ARCH)),)
  MY_MAGISK_SOURCE_PATH := $(MY_MAGISK_SOURCE_PATH_64)
else
  $(error Target architecture not supported: $(TARGET_ARCH))
endif

MY_MAGISK_SOURCE_INIT := $(MY_MAGISK_SOURCE_PATH)libmagiskinit.so
MY_MAGISK_SOURCE_64 := $(MY_MAGISK_SOURCE_PATH_64)libmagisk64.so
MY_MAGISK_SOURCE_32 := $(MY_MAGISK_SOURCE_PATH_32)libmagisk32.so

ifneq ($(filter arm arm64 ,$(HOST_ARCH)),)
  MY_MAGISK_SOURCE_PATH_32 := lib/armeabi-v7a/
  ifeq ($(shell test $(MY_MAGISK_MAJOR) -gt 23; echo $$?),0)
    MY_MAGISK_SOURCE_PATH_64 := lib/arm64-v8a/
  else
    MY_MAGISK_SOURCE_PATH_64 := $(MY_MAGISK_SOURCE_PATH_32)
  endif
else ifneq ($(filter x86 x86_64 ,$(HOST_ARCH)),)
  MY_MAGISK_SOURCE_PATH_32 := lib/x86/
  ifeq ($(shell test $(MY_MAGISK_MAJOR) -gt 23; echo $$?),0)
    MY_MAGISK_SOURCE_PATH_64 := lib/x86_64/
  else
    MY_MAGISK_SOURCE_PATH_64 := $(MY_MAGISK_SOURCE_PATH_32)
  endif
endif

ifneq ($(filter arm x86 ,$(HOST_ARCH)),)
  MY_MAGISK_SOURCE_PATH := $(MY_MAGISK_SOURCE_PATH_32)
else ifneq ($(filter arm64 x86_64 ,$(HOST_ARCH)),)
  MY_MAGISK_SOURCE_PATH := $(MY_MAGISK_SOURCE_PATH_64)
else
  $(error Host architecture not supported: $(TARGET_ARCH))
endif

MY_MAGISK_SOURCE_BOOT := $(MY_MAGISK_SOURCE_PATH)libmagiskboot.so

MY_MAGISK_TARGET_IMAGE := $(PRODUCT_OUT)/boot.img
MY_MAGISK_TARGET_ADDON := $(LOCAL_PATH)/$(LOCAL_SRC_FILES)
MY_MAGISK_TARGET_PATCH := $(MY_MAGISK_INTERMEDIATES)/boot_patch.sh
MY_MAGISK_TARGET_FUNCTIONS := $(MY_MAGISK_INTERMEDIATES)/util_functions.sh
MY_MAGISK_TARGET_STUB := $(MY_MAGISK_INTERMEDIATES)/stub.apk
MY_MAGISK_TARGET_BOOT := $(MY_MAGISK_INTERMEDIATES)/magiskboot
MY_MAGISK_TARGET_INIT := $(MY_MAGISK_INTERMEDIATES)/magiskinit
MY_MAGISK_TARGET_64 := $(MY_MAGISK_INTERMEDIATES)/magisk64
MY_MAGISK_TARGET_32 := $(MY_MAGISK_INTERMEDIATES)/magisk32

ifeq ($(shell test $(MY_MAGISK_MAJOR) -gt 25; echo $$?),0)
  MY_MAGISK_UNZIP_STUB := unzip -p $(MY_MAGISK_ARCHIVE) $(MY_MAGISK_SOURCE_STUB) > $(MY_MAGISK_TARGET_STUB)
else
  MY_MAGISK_UNZIP_STUB := :
endif

$(shell unzip -p $(MY_MAGISK_ARCHIVE) $(MY_MAGISK_SOURCE_ADDON) > $(MY_MAGISK_TARGET_ADDON) 2>/dev/null)
$(shell chmod 755 $(MY_MAGISK_TARGET_ADDON) 2>/dev/null)

LOCAL_POST_INSTALL_CMD := \
  rm -f $(MY_MAGISK_TARGET_ADDON) && \
  unzip -p $(MY_MAGISK_ARCHIVE) $(MY_MAGISK_SOURCE_PATCH) > $(MY_MAGISK_TARGET_PATCH); \
  unzip -p $(MY_MAGISK_ARCHIVE) $(MY_MAGISK_SOURCE_FUNCTIONS) > $(MY_MAGISK_TARGET_FUNCTIONS) && \
  $(MY_MAGISK_UNZIP_STUB) && \
  unzip -p $(MY_MAGISK_ARCHIVE) $(MY_MAGISK_SOURCE_BOOT) > $(MY_MAGISK_TARGET_BOOT) && \
  unzip -p $(MY_MAGISK_ARCHIVE) $(MY_MAGISK_SOURCE_INIT) > $(MY_MAGISK_TARGET_INIT) && \
  unzip -p $(MY_MAGISK_ARCHIVE) $(MY_MAGISK_SOURCE_64) > $(MY_MAGISK_TARGET_64) && \
  unzip -p $(MY_MAGISK_ARCHIVE) $(MY_MAGISK_SOURCE_32) > $(MY_MAGISK_TARGET_32) && \
  sed -i '1d' $(MY_MAGISK_TARGET_PATCH) && \
  chmod 755 $(MY_MAGISK_TARGET_PATCH) && \
  export OUTFD="1" && \
  $(MY_MAGISK_TARGET_PATCH) ../../../boot.img && \
  $(BOOT_SIGNER) /boot $(MY_MAGISK_SOURCE_IMAGE) $(MY_MAGISK_SIGNING_KEY).pk8 $(MY_MAGISK_SIGNING_KEY).x509.pem $(MY_MAGISK_SOURCE_IMAGE) && \
  $(AVBTOOL) add_hash_footer --image $(MY_MAGISK_SOURCE_IMAGE) --partition_size $(BOARD_BOOTIMAGE_PARTITION_SIZE) --partition_name boot $(MY_MAGISK_SIGNING_ARGS) && \
  mv -f $(MY_MAGISK_SOURCE_IMAGE) $(MY_MAGISK_TARGET_IMAGE)

include $(BUILD_PREBUILT)
