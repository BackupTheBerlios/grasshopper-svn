#############################################################
#
# zlib
#
#############################################################
ZLIB_VER:=1.2.3
ZLIB_SOURCE:=zlib-$(ZLIB_VER).tar.bz2
ZLIB_CAT:=$(BZCAT)
ZLIB_SITE:=http://www.zlib.net/
ZLIB_DIR:=$(BUILD_DIR)/zlib-$(ZLIB_VER)
ZLIB_CFLAGS:=$(TARGET_CFLAGS) -fPIC
ifeq ($(BR2_LARGEFILE),y)
ZLIB_CFLAGS+=-D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64
endif

$(DL_DIR)/$(ZLIB_SOURCE):
	$(WGET) -P $(DL_DIR) $(ZLIB_SITE)/$(ZLIB_SOURCE)

$(ZLIB_DIR)/.patched: $(DL_DIR)/$(ZLIB_SOURCE)
	$(ZLIB_CAT) $(DL_DIR)/$(ZLIB_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	toolchain/patch-kernel.sh $(ZLIB_DIR) package/zlib/ zlib\*.patch
	$(CONFIG_UPDATE) $(@D)
	touch $@

$(ZLIB_DIR)/.configured: $(ZLIB_DIR)/.patched
	(cd $(ZLIB_DIR); rm -rf config.cache ; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) $(ZLIB_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
		--shared \
		--prefix=/usr \
		--exec-prefix=$(STAGING_DIR)/usr/bin \
		--libdir=$(STAGING_DIR)/usr/lib \
		--includedir=$(STAGING_DIR)/usr/include \
	);
	touch $@

$(ZLIB_DIR)/libz.so.$(ZLIB_VER): $(ZLIB_DIR)/.configured
	$(MAKE) -C $(ZLIB_DIR) all libz.a
	touch -c $(ZLIB_DIR)/libz.so.$(ZLIB_VER)

$(STAGING_DIR)/usr/lib/libz.so.$(ZLIB_VER): $(ZLIB_DIR)/libz.so.$(ZLIB_VER)
	cp -dpf $(ZLIB_DIR)/libz.a $(STAGING_DIR)/usr/lib/
	cp -dpf $(ZLIB_DIR)/zlib.h $(STAGING_DIR)/usr/include/
	cp -dpf $(ZLIB_DIR)/zconf.h $(STAGING_DIR)/usr/include/
	cp -dpf $(ZLIB_DIR)/libz.so* $(STAGING_DIR)/usr/lib/
	ln -sf libz.so.$(ZLIB_VER) $(STAGING_DIR)/usr/lib/libz.so.1
	chmod a-x $(STAGING_DIR)/usr/lib/libz.so.$(ZLIB_VER)
	touch -c $@

$(TARGET_DIR)/usr/lib/libz.so.$(ZLIB_VER): $(STAGING_DIR)/usr/lib/libz.so.$(ZLIB_VER)
	cp -dpf $(STAGING_DIR)/usr/lib/libz.so* $(TARGET_DIR)/usr/lib
	-$(STRIP) --strip-unneeded $(TARGET_DIR)/usr/lib/libz.so*
	touch -c $@

$(TARGET_DIR)/usr/lib/libz.a: $(STAGING_DIR)/usr/lib/libz.so.$(ZLIB_VER)
	mkdir -p $(TARGET_DIR)/usr/include
	cp -dpf $(STAGING_DIR)/usr/include/zlib.h $(TARGET_DIR)/usr/include/
	cp -dpf $(STAGING_DIR)/usr/include/zconf.h $(TARGET_DIR)/usr/include/
	cp -dpf $(STAGING_DIR)/usr/lib/libz.a $(TARGET_DIR)/usr/lib/
	rm -f $(TARGET_DIR)/lib/libz.so
	ln -sf libz.so.$(ZLIB_VER) $(TARGET_DIR)/usr/lib/libz.so
	touch -c $@

zlib-headers: $(TARGET_DIR)/usr/lib/libz.a

zlib: uclibc $(TARGET_DIR)/usr/lib/libz.so.$(ZLIB_VER)

zlib-source: $(DL_DIR)/$(ZLIB_SOURCE)

zlib-clean:
	rm -f $(TARGET_DIR)/usr/lib/libz.so* \
		$(TARGET_DIR)/usr/include/z{lib,conf}.h
	-$(MAKE) -C $(ZLIB_DIR) clean

zlib-dirclean:
	rm -rf $(ZLIB_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_ZLIB)),y)
TARGETS+=zlib
endif
ifeq ($(strip $(BR2_PACKAGE_ZLIB_TARGET_HEADERS)),y)
TARGETS+=zlib-headers
endif
