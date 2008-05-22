alsa-plugins: alsa-lib $(BUILD_DIR)/alsa-plugins-$(ALSA_VERSION)/.installed

ifeq ($(BR2_PACKAGE_ALSA_LIB_PLUGINS),y)
ALSA_TARGETS+=alsa-plugins
endif

