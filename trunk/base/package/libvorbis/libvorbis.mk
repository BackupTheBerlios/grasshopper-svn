
#############################################################
#
# libvorbis
#
#############################################################
LIBVORBIS_VERSION:=1.2.2
LIBVORBIS_SOURCE:=libvorbis-$(LIBVORBIS_VERSION).tar.gz
LIBVORBIS_SITE:=http://downloads.xiph.org/releases/vorbis
LIBVORBIS_CAT:=$(ZCAT)
LIBVORBIS_DIR:=$(BUILD_DIR)/libvorbis-$(LIBVORBIS_VERSION)

$(DL_DIR)/$(LIBVORBIS_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBVORBIS_SITE)/$(LIBVORBIS_SOURCE)

libvorbis-source: $(DL_DIR)/$(LIBVORBIS_SOURCE)

$(LIBVORBIS_DIR)/.unpacked: $(DL_DIR)/$(LIBVORBIS_SOURCE)
	$(LIBVORBIS_CAT) $(DL_DIR)/$(LIBVORBIS_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	toolchain/patch-kernel.sh $(LIBVORBIS_DIR) package/libvorbis/ libvorbis\*.patch
	touch $(LIBVORBIS_DIR)/.unpacked

$(LIBVORBIS_DIR)/.configured: $(LIBVORBIS_DIR)/.unpacked
	(cd $(LIBVORBIS_DIR); \
	$(TARGET_CONFIGURE_OPTS) \
	CFLAGS="$(TARGET_CFLAGS) -I$(STAGING_DIR)/usr/include" \
	LDFLAGS="-L$(STAGING_DIR)/lib -L$(STAGING_DIR)/usr/lib" \
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
	touch $(LIBVORBIS_DIR)/.configured

$(LIBVORBIS_DIR)/.compiled: $(LIBVORBIS_DIR)/.configured
	$(MAKE) -C $(LIBVORBIS_DIR)
	touch $(LIBVORBIS_DIR)/.compiled

$(STAGING_DIR)/usr/lib/liblibvorbis.so: $(LIBVORBIS_DIR)/.compiled
	$(MAKE) DESTDIR=$(STAGING_DIR) -C $(LIBVORBIS_DIR) install
	touch -c $(STAGING_DIR)/lib/libvorbis.so

$(TARGET_DIR)/usr/lib/libvorbis.so: $(STAGING_DIR)/usr/lib/libvorbis.so
	cp -dpf $(STAGING_DIR)/usr/lib/libvorbis* $(TARGET_DIR)/usr/lib/
	-$(STRIP) --strip-unneeded \
		$(TARGET_DIR)/usr/lib/liblibvorbis.so

libvorbis: $(TARGET_DIR)/usr/lib/libvorbis.so

libvorbis-clean:
	$(MAKE) DESTDIR=$(TARGET_DIR) CC=$(TARGET_CC) -C $(LIBVORBIS_DIR) uninstall
	-$(MAKE) -C $(LIBVORBIS_DIR) clean

libvorbis-dirclean:
	rm -rf $(LIBVORBIS_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_LIBVORBIS)),y)
TARGETS+=libvorbis
endif
