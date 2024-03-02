# Copyright (C) 2023 Findlay Feng <i@fengch.me>

include $(TOPDIR)/rules.mk

PKG_NAME:=hysteria
PKG_VERSION:=1.3.5
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/apernet/hysteria.git
PKG_MIRROR_HASH:=6cb5195cc4e08ad696b8d1c08cf36d6f4086ab61c532f875895e75d3f5944f5a
PKG_SOURCE_VERSION:=57c5164854d6cfe00bead730cce731da2babe406

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.md
PKG_MAINTAINER:=Findlay Feng <i@fengch.me>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1

GO_PKG:=github.com/apernet/hysteria/app/cmd
GO_PKG_LDFLAGS_X:= \
	main.appDate=$(shell date -u '+%F.%T') \
	main.appVersion=v$(PKG_VERSION) \
	main.appCommit=$(PKG_SOURCE_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/hysteria
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Web Servers/Proxies
	TITLE:=A feature-packed proxy & relay tool optimized for lossy
	URL:=https://hysteria.network
	DEPENDS+=+jq +jd
endef

define Package/hysteria/description
	Hysteria is a feature-packed proxy & relay tool optimized for lossy,
	unstable connections (e.g. satellite networks, congested public Wi-Fi,
	connecting to foreign servers from China) powered
	by a customized protocol based on QUIC.
endef

define Build/Compile
	$(call GoPackage/Build/Compile)
endef

define Package/hysteria/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))

	$(INSTALL_DIR) $(1)/usr/bin $(1)/etc/init.d $(1)/etc/config $(1)/etc/sysctl.d

	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/cmd $(1)/usr/bin/hysteria
	$(INSTALL_BIN) ./files/hysteria.init $(1)/etc/init.d/hysteria
	$(INSTALL_DATA) ./files/hysteria.config $(1)/etc/config/hysteria
	$(INSTALL_DATA) ./files/sysctl-hysteria.conf $(1)/etc/sysctl.d/11-hysteria.conf
endef

define Package/hysteria/conffiles
	/etc/config/hysteria
endef

$(eval $(call GoBinPackage,hysteria))
$(eval $(call BuildPackage,hysteria))
