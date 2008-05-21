ALSA_UTILS_FILE:=alsa-utils-$(ALSA_VERSION).tar.bz2
ALSA_UTILS_SITE:=$(ALSA_SITE)/utils/$(ALSA_UTILS_FILE)

alsa-utils: ncurses gettext alsa-lib $(DL_DIR)/$(ALSA_UTILS_FILE) $(BUILD_DIR)/alsa-utils-$(ALSA_VERSION)/.installed

ifeq ($(BR2_PACKAGE_ALSA_UTILS),y)
ALSA_TARGETS+=alsa-utils
endif

