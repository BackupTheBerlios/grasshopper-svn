#############################################################
#
# rs232_proxy
#
#############################################################
RS232PROXY_VERSION:=0.1
RS232PROXY_SOURCE:=rs232_proxy-$(RS232PROXY_VERSION).tar.gz
RS232PROXY_SITE:=
RS232PROXY_DIR:=$(BUILD_DIR)/rs232_proxy-$(RS232PROXY_VERSION)
RS232PROXY_BINARY:=src/rs232_proxy
RS232PROXY_TARGET_BINARY:=usr/bin/rs232_proxy
RS232PROXY_ZCAT:=$(ZCAT)

$(DL_DIR)/$(RS232PROXY_SOURCE):
	echo "Please get a copy of the rs232proxy!"
	cp $(TOPDIR)/local/rs232proxy/$(RS232PROXY_SOURCE) $(DL_DIR)/
#	$(WGET) -P $(DL_DIR) $(RS232PROXY_SITE)/$(RS232PROXY_SOURCE)

$(RS232PROXY_DIR)/.source: $(DL_DIR)/$(RS232PROXY_SOURCE)
	$(RS232PROXY_ZCAT) $(DL_DIR)/$(RS232PROXY_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	touch $(RS232PROXY_DIR)/.source

$(RS232PROXY_DIR)/.configured: $(RS232PROXY_DIR)/.source
	(cd $(RS232PROXY_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=/usr \
		--sysconfdir=/etc \
	);
	touch $(RS232PROXY_DIR)/.configured;

$(RS232PROXY_DIR)/$(RS232PROXY_BINARY): $(RS232PROXY_DIR)/.configured
	$(MAKE) CC=$(TARGET_CC) -C $(RS232PROXY_DIR)

$(TARGET_DIR)/$(RS232PROXY_TARGET_BINARY): $(RS232PROXY_DIR)/$(RS232PROXY_BINARY)
	$(MAKE) prefix=$(TARGET_DIR)/usr -C $(RS232PROXY_DIR) install
	rm -Rf $(TARGET_DIR)/usr/man

rs232_proxy: uclibc $(TARGET_DIR)/$(RS232PROXY_TARGET_BINARY)

rs232_proxy-source: $(DL_DIR)/$(RS232PROXY_SOURCE)

rs232_proxy-clean:
	$(MAKE) prefix=$(TARGET_DIR)/usr -C $(RS232PROXY_DIR) uninstall
	-$(MAKE) -C $(RS232PROXY_DIR) clean

rs232_proxy-dirclean:
	rm -rf $(RS232PROXY_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_RS232PROXY)),y)
TARGETS+=rs232_proxy
endif
