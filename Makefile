# Copyright (C) 2023 Findlay Feng <i@fengch.me>

include $(TOPDIR)/rules.mk

PKG_NAME:=hysteria
PKG_VERSION:=2.2.4
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/apernet/hysteria.git
PKG_MIRROR_HASH:=efc0fb47d43ba022ea4f2b7b296f80d43d6f75c5a57543364e9ea90b3fd81b66
PKG_SOURCE_VERSION:=80bc3b3a443268d9c89b0f82071ec7f38006a1ba

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.md
PKG_MAINTAINER:=Findlay Feng <i@fengch.me>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-values.mk

GO_PKG:=github.com/apernet/hysteria
GO_PKG_BUILD_PKG=$(GO_PKG)/app
GO_PKG_LDFLAGS_X:= \
	$(GO_PKG)/app/cmd.appDate=$(shell date -u '+%F.%T') \
	$(GO_PKG)/app/cmd.appVersion=v$(PKG_VERSION) \
	$(GO_PKG)/app/cmd.appCommit=$(PKG_SOURCE_VERSION) \
	$(GO_PKG)/app/cmd.appPlatform=linux \
	$(GO_PKG)/app/cmd.appType=release \
	$(GO_PKG)/app/cmd.appArch=$(GO_ARCH)

include $(GO_INCLUDE_DIR)/golang-package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Web Servers/Proxies
	TITLE:=A feature-packed proxy & relay tool optimized for lossy
	URL:=https://hysteria.network
	USERID:=hysteria=102:hysteria=102
endef

define Package/$(PKG_NAME)/description
	Hysteria is a feature-packed proxy & relay tool optimized for lossy,
	unstable connections (e.g. satellite networks, congested public Wi-Fi,
	connecting to foreign servers from China) powered
	by a customized protocol based on QUIC.
endef

define Build/Compile
	$(call GoPackage/Build/Compile)
endef

define Package/$(PKG_NAME)/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))

	$(INSTALL_DIR) \
		$(1)/usr/bin \
		$(1)/lib/upgrade/keep.d \
		$(1)/etc/init.d \
		$(1)/etc/config \
		$(1)/etc/sysctl.d \
		$(1)/etc/capabilities \
		$(1)/etc/$(PKG_NAME)

	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/bin/app $(1)/usr/bin/$(PKG_NAME)
	$(INSTALL_BIN) \
		./files/hysteria.init $(1)/etc/init.d/$(PKG_NAME)
	
	$(INSTALL_CONF) ./files/hysteria.config $(1)/etc/config/$(PKG_NAME)
	$(INSTALL_CONF) ./files/sysctl-hysteria.conf $(1)/etc/sysctl.d/11-$(PKG_NAME).conf
	$(INSTALL_CONF) ./files/hysteria.json $(1)/etc/capabilities/$(PKG_NAME).json

	$(INSTALL_DATA) ./files/configs/* $(1)/etc/$(PKG_NAME)/
endef

define Package/$(PKG_NAME)/conffiles
/etc/config/$(PKG_NAME)
/etc/${PKG_NAME}/
endef

$(eval $(call GoBinPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)))
