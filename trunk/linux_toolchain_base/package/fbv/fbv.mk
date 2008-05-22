#############################################################
#
# fbv
#
#############################################################
FBV_VERSION:=1.0b
FBV_SOURCE:=fbv-$(FBV_VERSION).tar.gz
FBV_SITE:=http://s-tech.elsat.net.pl/fbv
FBV_DIR:=$(BUILD_DIR)/fbv-$(FBV_VERSION)
FBV_BINARY:=fbv
FBV_TARGET_BINARY:=usr/bin/fbv

$(DL_DIR)/$(FBV_SOURCE):
	$(WGET) -P $(DL_DIR) $(FBV_SITE)/$(FBV_SOURCE)

$(FBV_DIR)/.source: $(DL_DIR)/$(FBV_SOURCE)
	$(ZCAT) $(DL_DIR)/$(FBV_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	touch $(FBV_DIR)/.source

$(FBV_DIR)/.configured: $(FBV_DIR)/.source
	(cd $(FBV_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		./configure \
		--prefix=/usr \
		--without-libungif \
		"--libs=-lz -ljpeg -lpng" \
	);
	touch $(FBV_DIR)/.configured;

$(FBV_DIR)/$(FBV_BINARY): $(FBV_DIR)/.configured
	$(MAKE) CC=$(TARGET_CC) -C $(FBV_DIR)

$(TARGET_DIR)/$(FBV_TARGET_BINARY): $(FBV_DIR)/$(FBV_BINARY)
	cp $< $@

fbv: uclibc libpng jpeg $(TARGET_DIR)/$(FBV_TARGET_BINARY)

fbv-source: $(DL_DIR)/$(FBV_SOURCE)

fbv-clean:
	$(MAKE) prefix=$(TARGET_DIR)/usr -C $(FBV_DIR) uninstall
	-$(MAKE) -C $(FBV_DIR) clean

fbv-dirclean:
	rm -rf $(FBV_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_FBV)),y)
TARGETS+=fbv
endif
