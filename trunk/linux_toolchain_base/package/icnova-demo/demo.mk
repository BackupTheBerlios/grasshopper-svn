#############################################################
#
# ICNova Demo
#
#############################################################
DEMO_VERSION:=1
DEMO_FILE:=icnova-demo-$(DEMO_VERSION).tar.bz2

demo: $(DL_DIR)/$(DEMO_FILE) $(BUILD_DIR)/icnova-demo-$(DEMO_VERSION)/.installed

ifeq ($(BR2_PACKAGE_DEMO),y)
TARGETS+=demo
endif
