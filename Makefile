# Copyright (C) 2023 Findlay Feng <i@fengch.me>

include $(TOPDIR)/rules.mk

PKG_NAME:=hysteria
PKG_VERSION:=2.3.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/apernet/hysteria.git
PKG_MIRROR_HASH:=e4ddef9ab3fbf72281ba57cdb9ea4a503babdaa7d34897546e5719ae31bfeafa
PKG_SOURCE_VERSION:=c74c3fea15225ffce5e5028dd0b5c9881aa75c27

PKG_LICENSE:=MIT
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
endef

define Package/$(PKG_NAME)-configs
	$(call Package/$(PKG_NAME))
	TITLE:=configs
	DEPENDS:=$(PKG_NAME)
	USERID:=hysteria=102:hysteria=102
endef

define Package/$(PKG_NAME)-serverd
	$(call Package/$(PKG_NAME))
	TITLE:=server init scripts
	DEPENDS:=$(PKG_NAME) +$(PKG_NAME)-configs
endef

define Package/$(PKG_NAME)-clientd
	$(call Package/$(PKG_NAME))
	TITLE:=client init scripts
	DEPENDS:=$(PKG_NAME) +$(PKG_NAME)-configs \
		+kmod-nft-tproxy +kmod-nft-socket \
		+dnsmasq-full
endef

define Package/$(PKG_NAME)/description
	Hysteria is a feature-packed proxy & relay tool optimized for lossy,
	unstable connections (e.g. satellite networks, congested public Wi-Fi,
	connecting to foreign servers from China) powered
	by a customized protocol based on QUIC.
endef

define Package/$(PKG_NAME)-configs/description
	$(call Package/$(PKG_NAME)/description)
endef

define Package/$(PKG_NAME)-serverd/description
	$(call Package/$(PKG_NAME)/description)
endef

define Package/$(PKG_NAME)-clientd/description
	$(call Package/$(PKG_NAME)/description)
endef

define Build/Compile
	$(call GoPackage/Build/Compile)
endef

define Package/$(PKG_NAME)/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))

	$(INSTALL_DIR) $(1)/usr/bin $(1)/etc/sysctl.d
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/app $(1)/usr/bin/$(PKG_NAME)

	$(INSTALL_CONF) ./files/sysctl-hysteria.conf $(1)/etc/sysctl.d/11-$(PKG_NAME).conf
endef

define Package/$(PKG_NAME)-configs/install
	$(INSTALL_DIR) \
		$(1)/etc/config \
		$(1)/etc/capabilities

	$(INSTALL_CONF) ./files/hysteria.json $(1)/etc/capabilities/$(PKG_NAME).json
	$(INSTALL_CONF) ./files/hysteria.config $(1)/etc/config/$(PKG_NAME)
endef

define Package/$(PKG_NAME)-serverd/install
	$(INSTALL_DIR) \
		$(1)/etc/init.d \
		$(1)/etc/$(PKG_NAME)

	$(INSTALL_BIN) ./files/hysteria-serverd.init $(1)/etc/init.d/$(PKG_NAME)-serverd
	$(INSTALL_DATA) ./files/configs/server.yaml $(1)/etc/$(PKG_NAME)/
endef

define Package/$(PKG_NAME)-clientd/install
	$(INSTALL_DIR) \
		$(1)/etc/init.d \
		$(1)/usr/share/$(PKG_NAME)/bin \
		$(1)/etc/$(PKG_NAME)

	$(INSTALL_BIN) ./files/hysteria.init $(1)/etc/init.d/$(PKG_NAME)
	$(INSTALL_BIN) ./files/bin/hysteria-tproxy.sh $(1)/usr/share/$(PKG_NAME)/bin/set-tproxy
	$(INSTALL_DATA) ./files/configs/client.yaml $(1)/etc/$(PKG_NAME)/
endef

define Package/$(PKG_NAME)-configs/conffiles
/etc/config/$(PKG_NAME)
endef

define Package/$(PKG_NAME)-serverd/conffiles
/etc/${PKG_NAME}/
endef

define Package/$(PKG_NAME)-clientd/conffiles
/etc/${PKG_NAME}/
endef

$(eval $(call GoBinPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)-configs))
$(eval $(call BuildPackage,$(PKG_NAME)-serverd))
$(eval $(call BuildPackage,$(PKG_NAME)-clientd))
