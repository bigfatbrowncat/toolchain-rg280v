################################################################################
#
# dosfstools
#
################################################################################

DOSFSTOOLS_VERSION = 4.2
DOSFSTOOLS_SOURCE = dosfstools_$(DOSFSTOOLS_VERSION).orig.tar.gz
DOSFSTOOLS_SITE = http://deb.debian.org/debian/pool/main/d/dosfstools/
DOSFSTOOLS_LICENSE = GPLv3+
DOSFSTOOLS_LICENSE_FILES = COPYING

DOSFSTOOLS_AUTORECONF = YES

# Avoid target dosfstools dependencies, no host-libiconv
HOST_DOSFSTOOLS_DEPENDENCIES = 

DOSFSTOOLS_CFLAGS = $(TARGET_CFLAGS) -D_GNU_SOURCE

ifneq ($(BR2_ENABLE_LOCALE),y)
DOSFSTOOLS_DEPENDENCIES += libiconv
DOSFSTOOLS_LDLIBS += -liconv
endif

FATLABEL_BINARY = fatlabel
FSCK_FAT_BINARY = fsck.fat
MKFS_FAT_BINARY = mkfs.fat

define DOSFSTOOLS_BUILD_CMDS
	$(MAKE) $(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(DOSFSTOOLS_CFLAGS)" LDLIBS="$(DOSFSTOOLS_LDLIBS)" -C $(@D)
endef

DOSFSTOOLS_INSTALL_BIN_FILES_$(BR2_PACKAGE_DOSFSTOOLS_FATLABEL)+=src/$(FATLABEL_BINARY)
DOSFSTOOLS_INSTALL_BIN_FILES_$(BR2_PACKAGE_DOSFSTOOLS_FSCK_FAT)+=src/$(FSCK_FAT_BINARY)
DOSFSTOOLS_INSTALL_BIN_FILES_$(BR2_PACKAGE_DOSFSTOOLS_MKFS_FAT)+=src/$(MKFS_FAT_BINARY)

define DOSFSTOOLS_INSTALL_TARGET_CMDS
	test -z "$(DOSFSTOOLS_INSTALL_BIN_FILES_y)" || \
	$(INSTALL) -m 755 $(addprefix $(@D)/,$(DOSFSTOOLS_INSTALL_BIN_FILES_y)) \
		$(TARGET_DIR)/sbin/
endef

define DOSFSTOOLS_CONFIGURE_CMDS
	(cd $(@D); \
		./configure --without-iconv \
	)
endef

define HOST_DOSFSTOOLS_CONFIGURE_CMDS
        (cd $(@D); \
                ./configure --without-iconv \
        )
endef

define HOST_DOSFSTOOLS_BUILD_CMDS
	$(MAKE) $(HOST_CONFIGURE_OPTS) -C $(@D)
endef

define HOST_DOSFSTOOLS_INSTALL_CMDS
	$(MAKE) -C $(@D) $(HOST_CONFIGURE_OPTS) PREFIX=$(HOST_DIR)/usr install
endef

$(eval $(generic-package))
$(eval $(host-generic-package))
