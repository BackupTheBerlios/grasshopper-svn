
#############################################################
#
# fusionsound
#
#############################################################
FUSIONSOUND_VERSION:=1.0.0
FUSIONSOUND_SOURCE:=FusionSound-$(FUSIONSOUND_VERSION).tar.gz
FUSIONSOUND_SITE:=http://www.directfb.org/downloads/CORE
FUSIONSOUND_CAT:=$(ZCAT)
FUSIONSOUND_DIR:=$(BUILD_DIR)/FusionSound-$(FUSIONSOUND_VERSION)

$(DL_DIR)/$(FUSIONSOUND_SOURCE):
	$(WGET) -P $(DL_DIR) $(FUSIONSOUND_SITE)/$(FUSIONSOUND_SOURCE)

fusionsound-source: $(DL_DIR)/$(FUSIONSOUND_SOURCE)

$(FUSIONSOUND_DIR)/.unpacked: $(DL_DIR)/$(FUSIONSOUND_SOURCE)
	$(FUSIONSOUND_CAT) $(DL_DIR)/$(FUSIONSOUND_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	toolchain/patch-kernel.sh $(FUSIONSOUND_DIR) package/fusionsound/ fusionsound\*.patch
	touch $(FUSIONSOUND_DIR)/.unpacked

$(FUSIONSOUND_DIR)/.configured: $(FUSIONSOUND_DIR)/.unpacked
	(cd $(FUSIONSOUND_DIR); \
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
		--enable-vorbis \
		);
	touch $(FUSIONSOUND_DIR)/.configured

$(FUSIONSOUND_DIR)/.compiled: $(FUSIONSOUND_DIR)/.configured
	$(MAKE) -C $(FUSIONSOUND_DIR)
	touch $(FUSIONSOUND_DIR)/.compiled

$(STAGING_DIR)/usr/lib/libfusionsound.so: $(FUSIONSOUND_DIR)/.compiled
	$(MAKE) DESTDIR=$(STAGING_DIR) -C $(FUSIONSOUND_DIR) install
	touch -c $(STAGING_DIR)/lib/libfusionsound.so

$(TARGET_DIR)/usr/lib/libfusionsound.so: $(STAGING_DIR)/usr/lib/libfusionsound.so
	cp -dpf $(STAGING_DIR)/usr/lib/libfusionsound* $(TARGET_DIR)/usr/lib/
	cp -rdpf $(STAGING_DIR)/usr/lib/fusionsound-* $(TARGET_DIR)/usr/lib/
	-$(STRIP) --strip-unneeded \
		$(TARGET_DIR)/usr/lib/libfusionsound.so

fusionsound: directfb libvorbis $(TARGET_DIR)/usr/lib/libfusionsound.so

fusionsound-clean:
	$(MAKE) DESTDIR=$(TARGET_DIR) CC=$(TARGET_CC) -C $(FUSIONSOUND_DIR) uninstall
	-$(MAKE) -C $(FUSIONSOUND_DIR) clean

fusionsound-dirclean:
	rm -rf $(FUSIONSOUND_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_FUSIONSOUND)),y)
TARGETS+=fusionsound
endif
