################################################################################
#
# mesa3d 10.2.5>>11.0.9
#
################################################################################

MESA3D_VERSION = 19.0.1
MESA3D_SOURCE = mesa-$(MESA3D_VERSION).tar.gz
MESA3D_SITE = https://archive.mesa3d.org/
MESA3D_LICENSE = MIT, SGI, Khronos
MESA3D_LICENSE_FILES = docs/license.html
MESA3D_AUTORECONF = YES

define MESA3D_RUN_AUTOGEN
	cd $(@D) && PATH=$(BR_PATH) ./autogen.sh
endef
MESA3D_CONFIGURE_HOOKS += MESA3D_RUN_AUTOGEN

MESA3D_INSTALL_STAGING = YES

#for rogue
MESA3D_CONF_OPT = \
	--enable-autotools \
	--disable-dri3 \
	--disable-driglx-direct \
	--disable-xlib-lease \
	--with-platforms=drm

MESA3D_PROVIDES =

MESA3D_DEPENDENCIES = \
	expat \
	host-meson \
	host-ninja \
	host-bison \
	host-flex \
	host-gettext \
	host-libxml2 \
	host-python3-mako \
	host-xutil_makedepend \
	libdrm

ifeq ($(BR2_PACKAGE_XORG7),y)
MESA3D_DEPENDENCIES += \
	xproto_xf86driproto \
	xproto_dri2proto \
	xproto_glproto \
	xlib_libX11 \
	xlib_libXext \
	xlib_libXdamage \
	xlib_libXfixes \
	libxcb
MESA3D_CONF_OPT += --enable-glx
# quote from mesa3d configure "Building xa requires at least one non swrast gallium driver."
ifneq ($(BR2_PACKAGE_MESA3D_GALLIUM_DRIVER_NOUVEAU)$(BR2_PACKAGE_MESA3D_GALLIUM_DRIVER_SVGA),)
MESA3D_CONF_OPT += --enable-xa
else
MESA3D_CONF_OPT += --disable-xa
endif
else
MESA3D_CONF_OPT += \
	--disable-glx \
	--disable-xa
endif

ifeq ($(BR2_PREFER_STATIC_LIB),)
# fix for "configure: error: Cannot use static libraries for DRI drivers"
MESA3D_CONF_OPT += --disable-static
endif

# Drivers

#Gallium Drivers
MESA3D_GALLIUM_DRIVERS-$(BR2_PACKAGE_MESA3D_GALLIUM_DRIVER_ETNAVIV)  += etnaviv
MESA3D_GALLIUM_DRIVERS-$(BR2_PACKAGE_MESA3D_GALLIUM_DRIVER_KMSRO) += kmsro
MESA3D_GALLIUM_DRIVERS-$(BR2_PACKAGE_MESA3D_GALLIUM_DRIVER_NOUVEAU)  += nouveau
MESA3D_GALLIUM_DRIVERS-$(BR2_PACKAGE_MESA3D_GALLIUM_DRIVER_SVGA)     += svga
MESA3D_GALLIUM_DRIVERS-$(BR2_PACKAGE_MESA3D_GALLIUM_DRIVER_SWRAST)   += swrast
# DRI Drivers
MESA3D_DRI_DRIVERS-$(BR2_PACKAGE_MESA3D_DRI_DRIVER_SWRAST) += swrast
MESA3D_DRI_DRIVERS-$(BR2_PACKAGE_MESA3D_DRI_DRIVER_KMSRO) += kmsro
MESA3D_DRI_DRIVERS-$(BR2_PACKAGE_MESA3D_DRI_DRIVER_I965)   += i965
MESA3D_DRI_DRIVERS-$(BR2_PACKAGE_MESA3D_DRI_DRIVER_RADEON) += radeon

ifeq ($(MESA3D_GALLIUM_DRIVERS-y),)
MESA3D_CONF_OPT += \
	--without-gallium-drivers
else
MESA3D_CONF_OPT += \
	--enable-shared-glapi \
	--with-gallium-drivers=$(subst $(space),$(comma),$(MESA3D_GALLIUM_DRIVERS-y))
endif

ifeq ($(MESA3D_DRI_DRIVERS-y),)
MESA3D_CONF_OPT += \
	--without-dri-drivers
else
ifeq ($(BR2_PACKAGE_XPROTO_DRI3PROTO),y)
MESA3D_DEPENDENCIES += xlib_libxshmfence xproto_dri3proto xproto_presentproto
MESA3D_CONF_OPT += --enable-dri3
else
MESA3D_CONF_OPT += --disable-dri3
endif
MESA3D_PROVIDES += libgl
MESA3D_CONF_OPT += \
	--enable-dri \
	--enable-shared-glapi \
	--with-dri-drivers=$(subst $(space),$(comma),$(MESA3D_DRI_DRIVERS-y))
endif

# APIs

# Always enable OpenGL:
#   - it is needed for GLES (mesa3d's ./configure is a bit weird)
#   - but if no DRI driver is enabled, then libgl is not built
MESA3D_CONF_OPT += --enable-opengl

ifeq ($(BR2_PACKAGE_MESA3D_OPENGL_EGL),y)
MESA3D_PROVIDES += libegl
# egl depends on gbm, gbm depends on udev
MESA3D_DEPENDENCIES += udev
MESA3D_EGL_PLATFORMS = drm
ifeq ($(BR2_PACKAGE_WAYLAND),y)
MESA3D_DEPENDENCIES += wayland
MESA3D_EGL_PLATFORMS += wayland
endif
ifeq ($(BR2_PACKAGE_XORG7),y)
MESA3D_EGL_PLATFORMS += x11
endif
MESA3D_CONF_OPT += \
	--enable-gbm \
	--enable-egl \
	--with-platforms=$(subst $(space),$(comma),$(MESA3D_EGL_PLATFORMS))
else
MESA3D_CONF_OPT += \
	--disable-egl
endif

ifeq ($(BR2_PACKAGE_MESA3D_OPENGL_ES),y)
MESA3D_PROVIDES += libgles
MESA3D_CONF_OPT += --enable-gles1 --enable-gles2
else
MESA3D_CONF_OPT += --disable-gles1 --disable-gles2
endif

$(eval $(autotools-package))
