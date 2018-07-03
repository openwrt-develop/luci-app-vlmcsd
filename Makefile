include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI page for KMS
LUCI_DEPENDS:=+vlmcsd
PKG_VERSION:=1.0
PKG_RELEASE:=2

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature