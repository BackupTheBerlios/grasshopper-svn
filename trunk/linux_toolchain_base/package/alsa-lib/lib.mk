ALSA_LIB_FILE:=alsa-lib-$(ALSA_VERSION).tar.bz2
ALSA_LIB_SITE:=$(ALSA_SITE)/lib/$(ALSA_LIB_FILE)

alsa-lib: $(DL_DIR)/$(ALSA_LIB_FILE) $(BUILD_DIR)/alsa-lib-$(ALSA_VERSION)/.libs

ifeq ($(BR2_PACKAGE_ALSA_LIB),y)
TARGETS+=alsa-lib
endif

