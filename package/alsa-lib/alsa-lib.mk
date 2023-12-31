################################################################################
#
# alsa-lib
#
################################################################################

ALSA_LIB_VERSION = 1.2.4
ALSA_LIB_SOURCE = alsa-lib-$(ALSA_LIB_VERSION).tar.bz2
ALSA_LIB_SITE = https://www.alsa-project.org/files/pub/lib
ALSA_LIB_LICENSE = LGPL-2.1+ (library), GPL-2.0+ (aserver)
ALSA_LIB_LICENSE_FILES = COPYING aserver/COPYING
ALSA_LIB_INSTALL_STAGING = YES
ALSA_LIB_CFLAGS = $(TARGET_CFLAGS)
ALSA_LIB_AUTORECONF = YES
ALSA_LIB_CONF_OPT = --with-alsa-devdir=$(call qstrip,$(BR2_PACKAGE_ALSA_LIB_DEVDIR)) \
		    --with-pcm-plugins="$(call qstrip,$(BR2_PACKAGE_ALSA_LIB_PCM_PLUGINS))" \
		    --with-ctl-plugins="$(call qstrip,$(BR2_PACKAGE_ALSA_LIB_CTL_PLUGINS))" \
		    --without-versioned \
			--disable-topology

# Can't build with static & shared at the same time (1.0.25+)
ifeq ($(BR2_PREFER_STATIC_LIB),y)
ALSA_LIB_CONF_OPT += --enable-shared=no \
					--without-libdl
else
ALSA_LIB_CONF_OPT += --enable-static=no
endif

ifneq ($(BR2_PACKAGE_ALSA_LIB_ALOAD),y)
ALSA_LIB_CONF_OPT += --disable-aload
endif
ifneq ($(BR2_PACKAGE_ALSA_LIB_MIXER),y)
ALSA_LIB_CONF_OPT += --disable-mixer
endif
ifneq ($(BR2_PACKAGE_ALSA_LIB_PCM),y)
ALSA_LIB_CONF_OPT += --disable-pcm
endif
ifneq ($(BR2_PACKAGE_ALSA_LIB_RAWMIDI),y)
ALSA_LIB_CONF_OPT += --disable-rawmidi
endif
ifneq ($(BR2_PACKAGE_ALSA_LIB_HWDEP),y)
ALSA_LIB_CONF_OPT += --disable-hwdep
endif
ifneq ($(BR2_PACKAGE_ALSA_LIB_SEQ),y)
ALSA_LIB_CONF_OPT += --disable-seq
endif
ifneq ($(BR2_PACKAGE_ALSA_LIB_UCM),y)
ALSA_LIB_CONF_OPT += --disable-ucm
endif
ifneq ($(BR2_PACKAGE_ALSA_LIB_ALISP),y)
ALSA_LIB_CONF_OPT += --disable-alisp
endif
ifneq ($(BR2_PACKAGE_ALSA_LIB_OLD_SYMBOLS),y)
ALSA_LIB_CONF_OPT += --disable-old-symbols
endif

ifeq ($(BR2_ENABLE_DEBUG),y)
ALSA_LIB_CONF_OPT += --enable-debug
endif

ifeq ($(BR2_avr32),y)
ALSA_LIB_CFLAGS += -DAVR32_INLINE_BUG
endif

ifeq ($(BR2_PACKAGE_ALSA_LIB_PYTHON),y)
ALSA_LIB_CONF_OPT += \
	--with-pythonlibs=-lpython$(PYTHON_VERSION_MAJOR) \
	--with-pythonincludes=$(STAGING_DIR)/usr/include/python$(PYTHON_VERSION_MAJOR)
ALSA_LIB_CFLAGS += -I$(STAGING_DIR)/usr/include/python$(PYTHON_VERSION_MAJOR)
ALSA_LIB_DEPENDENCIES = python
else
ALSA_LIB_CONF_OPT += --disable-python
endif

ifeq ($(BR2_SOFT_FLOAT),y)
ALSA_LIB_CONF_OPT += --with-softfloat
endif

ifeq ($(BR2_bfin),y)
# blackfin external toolchains don't have versionsort. Fake it using alphasort
# instead
ALSA_LIB_CFLAGS += -Dversionsort=alphasort
endif

ALSA_LIB_CONF_ENV = CFLAGS="$(ALSA_LIB_CFLAGS)" \
		    LDFLAGS="$(TARGET_LDFLAGS) -lm"

$(eval $(autotools-package))
