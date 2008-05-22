#############################################################
#
# kaffe
#
#############################################################
KAFFE_VERSION:=1.1.7
KAFFE_SOURCE:=kaffe-$(KAFFE_VERSION).tar.gz
KAFFE_SITE:=ftp://ftp.kaffe.org/pub/kaffe/v1.1.x-development/
KAFFE_DIR:=$(BUILD_DIR)/kaffe-$(KAFFE_VERSION)
KAFFE_BINARY:=kaffe/kaffe/kaffe-bin
KAFFE_TARGET_BINARY:=usr/bin/kaffe

KAFFE_CONFIGURE_OPTS:=--enable-portable-native-sync
ifdef ($(BR2_KAFFE_ENGINE))
KAFFE_CONFIGURE_OPTS+=--with-engine=$(BR2_KAFFE_ENGINE)
endif
ifneq ($(BR2_KAFFE_AWT),y)
KAFFE_CONFIGURE_OPTS+=--disable-native-awt
else
ifeq ($(BR2_KAFFE_AWT_X),y)
KAFFE_CONFIGURE_OPTS+=--with-kaffe-x-awt
endif
ifeq ($(BR2_KAFFE_AWT_QT),y)
KAFFE_CONFIGURE_OPTS+=--with-kaffe-qt-awt
endif
endif # BR2_KAFFE_AWT
ifneq ($(BR2_KAFFE_SOUND),y)
KAFFE_CONFIGURE_OPTS+=--disable-sound
endif
ifeq ($(BR2_KAFFE_JNI),y)
KAFFE_CONFIGURE_OPTS+=--enable-jni
else # BR2_KAFFE_JNI
KAFFE_CONFIGURE_OPTS+=--disable-jni
endif # BR2_KAFFE_JNI
ifneq ($(BR2_PACKAGE_LIBGTK2),y)
KAFFE_CONFIGURE_OPTS+=--disable-gtk-peer
endif
ifneq ($(BR2_KAFFE_AWT_QT),y)
KAFFE_CONFIGURE_OPTS+=--disable-qt-peer
endif

$(DL_DIR)/$(KAFFE_SOURCE):
	$(WGET) -P $(DL_DIR) $(KAFFE_SITE)/$(KAFFE_SOURCE)

$(KAFFE_DIR)/.source: $(DL_DIR)/$(KAFFE_SOURCE)
	$(ZCAT) $(DL_DIR)/$(KAFFE_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	touch $(KAFFE_DIR)/.source

$(KAFFE_DIR)/.configured: $(KAFFE_DIR)/.source
	(cd $(KAFFE_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=/usr \
		--sysconfdir=/etc \
		$(KAFFE_CONFIGURE_OPTS) \
	);
	touch $(KAFFE_DIR)/.configured;

$(KAFFE_DIR)/$(KAFFE_BINARY): $(KAFFE_DIR)/.configured
	$(MAKE) CC=$(TARGET_CC) -C $(KAFFE_DIR)

$(TARGET_DIR)/$(KAFFE_TARGET_BINARY): $(KAFFE_DIR)/$(KAFFE_BINARY)
	$(MAKE) DESTDIR=$(TARGET_DIR) -C $(KAFFE_DIR) install
	rm -Rf $(TARGET_DIR)/usr/man

kaffe: uclibc $(TARGET_DIR)/$(KAFFE_TARGET_BINARY)

kaffe-source: $(DL_DIR)/$(KAFFE_SOURCE)

kaffe-clean:
	$(MAKE) prefix=$(TARGET_DIR)/usr -C $(KAFFE_DIR) uninstall
	-$(MAKE) -C $(KAFFE_DIR) clean

kaffe-dirclean:
	rm -rf $(KAFFE_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_KAFFE)),y)
TARGETS+=kaffe
endif
