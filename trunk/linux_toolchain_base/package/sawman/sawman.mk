#############################################################
#
# sawman
#
#############################################################
SAWMAN_VERSION:=0.1.0
SAWMAN_SOURCE:=SaWMan-$(SAWMAN_VERSION).tar.gz
SAWMAN_SITE:=http://www.directfb.org/downloads/EXTRAS
SAWMAN_CAT:=$(ZCAT)
SAWMAN_DIR:=$(BUILD_DIR)/DirectFB-$(SAWMAN_VERSION)

$(DL_DIR)/$(SAWMAN_SOURCE):
	$(WGET) -P $(DL_DIR) $(SAWMAN_SITE)/$(SAWMAN_SOURCE)

sawman-source: $(DL_DIR)/$(SAWMAN_SOURCE)

$(SAWMAN_DIR)/.unpacked: $(DL_DIR)/$(SAWMAN_SOURCE)
	$(SAWMAN_CAT) $(DL_DIR)/$(SAWMAN_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	toolchain/patch-kernel.sh $(SAWMAN_DIR) package/sawman/ sawman\*.patch
	touch $(SAWMAN_DIR)/.unpacked

$(SAWMAN_DIR)/.configured: $(SAWMAN_DIR)/.unpacked
	(cd $(SAWMAN_DIR); \
	$(TARGET_CONFIGURE_OPTS) \
	CFLAGS="$(TARGET_CFLAGS) -I$(STAGING_DIR)/usr/include" \
	LDFLAGS="-L$(STAGING_DIR)/lib -L$(STAGING_DIR)/usr/lib" \
	ac_cv_header_linux_wm97xx_h=no \
	ac_cv_header_linux_sisfb_h=no \
	./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=/usr \
		--exec-prefix=/usr \
		--bindir=/usr/bin \
		--sbindir=/usr/sbin \
		--libdir=/lib \
		--libexecdir=/usr/lib \
		--sysconfdir=/etc \
		--datadir=/usr/share \
		--localstatedir=/var \
		--includedir=/usr/include \
		--mandir=/usr/man \
		--infodir=/usr/info \
		);
	touch $(SAWMAN_DIR)/.configured

$(SAWMAN_DIR)/.compiled: $(SAWMAN_DIR)/.configured
	$(MAKE) -C $(SAWMAN_DIR)
	touch $(SAWMAN_DIR)/.compiled

$(TARGET_DIR)/usr/bin/sawman: $(SAWMAN_DIR)/.compiled
	$(MAKE) DESTDIR=$(STAGING_DIR) -C $(SAWMAN_DIR) install

sawman: directfb $(TARGET_DIR)/usr/bin/sawman

sawman-clean:
	$(MAKE) DESTDIR=$(TARGET_DIR) CC=$(TARGET_CC) -C $(SAWMAN_DIR) uninstall
	-$(MAKE) -C $(SAWMAN_DIR) clean

sawman-dirclean:
	rm -rf $(SAWMAN_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_SAWMAN)),y)
TARGETS+=sawman
endif
