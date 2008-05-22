alsa-driver: $(BUILD_DIR)/alsa-driver-$(ALSA_VERSION)/.installed

ifeq ($(BR2_PACKAGE_ALSA_DRIVER),y)
ALSA_TARGETS+=alsa-driver
endif

