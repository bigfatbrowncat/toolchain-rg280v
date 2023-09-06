################################################################################
#
# pwswd
#
################################################################################

PWSWD_VERSION = master
PWSWD_SITE = $(call github,ninoh-fox,PWSWD,$(PWSWD_VERSION))

PWSWD_DEPENDENCIES = alsa-lib libini libpng

PWSWD_MAKE_ENV = CFLAGS="$(TARGET_CFLAGS) -I$(STAGING_DIR)/usr/include" LDFLAGS="$(TARGET_LDFLAGS)" \
				 CROSS_COMPILE="$(TARGET_CROSS)" \
				 CONFIG=$(BR2_PACKAGE_PWSWD_PLATFORM)

#PWSWD_MAKE_ENV = CONFIG=$(BR2_PACKAGE_PWSWD_PLATFORM)

define PWSWD_BUILD_CMDS
	$(PWSWD_MAKE_ENV) $(MAKE) -C $(@D)
endef

define PWSWD_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/pwswd $(TARGET_DIR)/usr/sbin/pwswd
	$(INSTALL) -D -m 0644 $(@D)/pwswd-$(BR2_PACKAGE_PWSWD_PLATFORM).conf $(TARGET_DIR)/etc/pwswd.conf
	$(INSTALL) -D -m 0755 package/pwswd/S91pwswd.sh $(TARGET_DIR)/etc/init.d/S91pwswd.sh
endef

$(eval $(generic-package))
