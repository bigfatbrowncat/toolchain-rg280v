################################################################################
#
# popt
#
################################################################################

POPT_VERSION = 1.18
# rpm5.org down
POPT_SOURCE = popt-$(POPT_VERSION).tar.gz
POPT_SITE = http://ftp.rpm.org/popt/releases/popt-1.x
POPT_INSTALL_STAGING = YES
POPT_LICENSE = MIT
POPT_LICENSE_FILES = COPYING
POPT_AUTORECONF = YES
POPT_GETTEXTIZE = YES

POPT_CONF_ENV = ac_cv_va_copy=yes

ifeq ($(BR2_PACKAGE_LIBICONV),y)
POPT_CONF_ENV += am_cv_lib_iconv=yes
POPT_CONF_OPT += --with-libiconv-prefix=$(STAGING_DIR)/usr
endif

$(eval $(autotools-package))
$(eval $(host-autotools-package))
