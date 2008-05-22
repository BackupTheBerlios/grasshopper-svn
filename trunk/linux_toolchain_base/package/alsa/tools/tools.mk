alsa-tools: alsa-lib $(BUILD_DIR)/alsa-tools-$(ALSA_VERSION)/.installed

ifeq ($(BR2_PACKAGE_ALSA_TOOLS),y)
ALSA_TARGETS+=alsa-tools
endif
