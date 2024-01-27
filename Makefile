#
# Copyright (C) 2007-2019 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=tinc-legacy
PKG_VERSION:=1.0.36
PKG_RELEASE:=3

PKG_SOURCE:=tinc-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.tinc-vpn.org/packages
PKG_HASH:=40f73bb3facc480effe0e771442a706ff0488edea7a5f2505d4ccb2aa8163108

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=extra
  CATEGORY:=Extra packages
  DEPENDS:=+liblzo +libopenssl +kmod-tun +zlib
  TITLE:=VPN tunneling daemon
  URL:=http://www.tinc-vpn.org/
  MAINTAINER:=Saverio Proto <zioproto@gmail.com>
endef

define Package/$(PKG_NAME)/description
  tinc is a Virtual Private Network (VPN) daemon that uses tunnelling and
  encryption to create a secure private network between hosts on the Internet.
endef

define Package/$(PKG_NAME)/config
menu "tinc-legacy Configuration"
        depends on PACKAGE_$(PKG_NAME)

config PACKAGE_TINC_LEGACY_RUN_AS_GROUP_NETWORK
        bool "Run as group network"
        default n

endmenu
endef

TARGET_CFLAGS += -std=gnu99

CONFIGURE_ARGS += \
	--with-kernel="$(LINUX_DIR)" \
	--with-zlib="$(STAGING_DIR)/usr" \
	--with-lzo-include="$(STAGING_DIR)/usr/include/lzo"

CONFIGURE_VARS += \
	ac_cv_have_decl_OpenSSL_add_all_algorithms=yes

define Build/Patch
	$(CP) $(PKG_BUILD_DIR)/../tinc-$(PKG_VERSION)/* $(PKG_BUILD_DIR)
	$(Build/Patch/Default)
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/tincd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d/
ifdef CONFIG_PACKAGE_TINC_LEGACY_RUN_AS_GROUP_NETWORK
	$(INSTALL_BIN) files/tinc.network $(1)/etc/init.d/$(PKG_NAME)
else
	$(INSTALL_BIN) files/tinc.init $(1)/etc/init.d/$(PKG_NAME)
endif
	$(INSTALL_DIR) $(1)/etc/tinc
	$(INSTALL_DIR) $(1)/lib/upgrade/keep.d
	$(INSTALL_DATA) files/tinc.upgrade $(1)/lib/upgrade/keep.d/tinc
endef

define Package/$(PKG_NAME)/conffiles
/etc/tinc/*
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
