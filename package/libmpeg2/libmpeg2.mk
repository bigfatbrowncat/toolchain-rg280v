################################################################################
#
# libmpeg2
#
################################################################################

LIBMPEG2_VERSION = 0.5.1
LIBMPEG2_SITE = http://libmpeg2.sourceforge.net/files
LIBMPEG2_LICENSE = GPLv2+
LIBMPEG2_LICENSE_FILES = COPYING
LIBMPEG2_INSTALL_STAGING = YES
LIBMPEG2_AUTORECONF = YES
LIBMPEG2_CONF_OPT = --without-x --disable-directx

ifeq ($(BR2_PACKAGE_SDL),y)
LIBMPEG2_CONF_ENV += ac_cv_prog_SDLCONFIG=$(STAGING_DIR)/usr/bin/sdl-config
LIBMPEG2_CONF_OPT += --enable-sdl
LIBMPEG2_DEPENDENCIES += sdl
ifeq ($(BR2_PACKAGE_SDL_COMPAT),y)
LIBMPEG2_DEPENDENCIES += sdl_compat
endif
else
LIBMPEG2_CONF_OPT += --disable-sdl
endif

ifneq ($(BR2_PACKAGE_LIBMPEG2_BINS),y)
define LIBMPEG2_REMOVE_BINS
	rm -f $(addprefix $(TARGET_DIR)/usr/bin/,\
		mpeg2dec corrupt_mpeg2 extract_mpeg2)
endef

LIBMPEG2_POST_INSTALL_TARGET_HOOKS += LIBMPEG2_REMOVE_BINS
endif

$(eval $(autotools-package))
