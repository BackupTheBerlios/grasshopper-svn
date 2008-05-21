#############################################################
#
# fusion-kernel
#
#############################################################
FUSION_KERNEL_VERSION:=3.2.3
FUSION_KERNEL_SOURCE:=linux-fusion-$(FUSION_KERNEL_VERSION).tar.gz
FUSION_KERNEL_SITE:=http://www.directfb.org/downloads/Core
FUSION_KERNEL_CAT:=$(ZCAT)
FUSION_KERNEL_DIR:=$(BUILD_DIR)/linux-fusion-$(FUSION_KERNEL_VERSION)

$(DL_DIR)/$(FUSION_KERNEL_SOURCE):
	$(WGET) -P $(DL_DIR) $(FUSION_KERNEL_SITE)/$(FUSION_KERNEL_SOURCE)

fusion-kernel-source: $(DL_DIR)/$(FUSION_KERNEL_SOURCE)

$(FUSION_KERNEL_DIR)/.unpacked: $(DL_DIR)/$(FUSION_KERNEL_SOURCE)
	$(FUSION_KERNEL_CAT) $(DL_DIR)/$(FUSION_KERNEL_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	toolchain/patch-kernel.sh $(FUSION_KERNEL_DIR) package/fusion-kernel/ fusion-kernel\*.patch
	touch $(FUSION_KERNEL_DIR)/.unpacked

$(FUSION_KERNEL_DIR)/linux/drivers/char/fusion: $(FUSION_KERNEL_DIR)/.unpacked
	DESTDIR=$(STAGING_DIR) CC=$(TARGET_CC) \
		KERNEL_VERSION=$(LINUX_HEADERS_VERSION) \
		KERNEL_MODLIB=$(TARGET_DIR)/lib/modules/$(LINUX_HEADERS_VERSION) \
		$(MAKE) -C $(FUSION_KERNEL_DIR) all

$(TARGET_DIR)/lib/modules/$(LINUX_HEADERS_VERSION)/drivers/char/fusion/fusion.ko: $(FUSION_KERNEL_DIR)/linux/drivers/char/fusion
	$(MAKE) DESTDIR=$(STAGING_DIR) CC=$(TARGET_CC) \
		KERNEL_VERSION=$(LINUX_HEADERS_VERSION) \
		KERNEL_MODLIB=$(TARGET_DIR)/lib/modules/$(LINUX_HEADERS_VERSION) \
		-C $(FUSION_KERNEL_DIR) install
	mv $(STAGING_DIR)/lib/modules/* $(TARGET_DIR)/lib/modules/

fusion-kernel: uclibc jpeg libpng freetype libsysfs $(TARGET_DIR)/lib/modules/$(LINUX_HEADERS_VERSION)/drivers/char/fusion/fusion.ko

fusion-kernel-clean:
	$(MAKE) DESTDIR=$(STAGING_DIR) CC=$(TARGET_CC) -C $(FUSION_KERNEL_DIR) uninstall
	-$(MAKE) -C $(FUSION_KERNEL_DIR) clean

fusion-kernel-dirclean:
	rm -rf $(FUSION_KERNEL_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_FUSION_KERNEL)),y)
TARGETS+=fusion-kernel
endif
