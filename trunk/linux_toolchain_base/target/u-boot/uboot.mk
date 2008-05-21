UBOOT_VERSION:=$(patsubst "%",%,$(UBOOT_VERSION) )
UBOOT_SOURCE:=u-boot-$(UBOOT_VERSION).tar.bz2
UBOOT_SITE=ftp://ftp.denx.de/pub/u-boot
UBOOT_CAT=$(BZCAT)
UBOOT_DIR=$(BUILD_DIR)/u-boot-$(UBOOT_VERSION)
UBOOT_BINARY=u-boot.bin
UBOOT_TARGET_DIR=.
UBOOT_PATCH_DIR=target/u-boot
ifeq ($(BR2_BOARD_ICNOVA_CP2102),y)
BR2_UBOOT_BOARD := $(BR2_UBOOT_BOARD)_cp2102
endif

$(DL_DIR)/$(UBOOT_SOURCE):
	$(WGET) -P $(DL_DIR) $(UBOOT_SITE)/$(UBOOT_SOURCE)

uboot-source: $(DL_DIR)/$(UBOOT_SOURCE)

$(UBOOT_DIR)/.unpacked: $(DL_DIR)/$(UBOOT_SOURCE)
	$(UBOOT_CAT) $(DL_DIR)/$(UBOOT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if [ "$(UBOOT_PATCH_DIR)" ]; then \
		toolchain/patch-kernel.sh $(UBOOT_DIR) $(UBOOT_PATCH_DIR) *$(UBOOT_VERSION)*.patch*; \
	fi
	touch $@

$(UBOOT_DIR)/.configured: $(UBOOT_DIR)/.unpacked
#	$(MAKE) CC=$(TARGET_CC) -C $(UBOOT_DIR) $(BR2_UBOOT_BOARD)_config
#	CROSS_COMPILE=$(BR2_STAGING_DIR)/bin/$(ARCH)-uclibc- 
		PATH=$(TARGET_PATH) \
		$(MAKE) -C $(UBOOT_DIR) $(BR2_UBOOT_BOARD)_config
	touch $@

$(UBOOT_DIR)/$(UBOOT_BINARY): $(UBOOT_DIR)/.configured
#	$(MAKE) CC=$(TARGET_CC) -C $(UBOOT_DIR)
#	CROSS_COMPILE=$(BR2_STAGING_DIR)/bin/$(ARCH)-uclibc- 
		PATH=$(TARGET_PATH) \
		$(MAKE) -C $(UBOOT_DIR)

$(UBOOT_DIR)/.installed: $(UBOOT_DIR)/$(UBOOT_BINARY)
	cp $(UBOOT_DIR)/$(UBOOT_BINARY) $(UBOOT_TARGET_DIR)/$(UBOOT_BINARY)
	cp $(UBOOT_DIR)/tools/mkimage $(STAGING_DIR)/bin
	touch $@

.PHONY: uboot

uboot: uclibc $(UBOOT_DIR)/.installed

uboot-clean:
	$(MAKE) -C $(UBOOT_DIR) clean
	rm -f $(UBOOT_TARGET_DIR)/$(UBOOT_BINARY)

uboot-dirclean:
		rm -rf $(UBOOT_DIR)


ifeq ($(strip $(BR2_TARGET_UBOOT)),y)
TARGETS += uboot
endif
