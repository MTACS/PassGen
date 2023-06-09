TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = Preferences
ARCHS = arm64 arm64e
SYSROOT = $(THEOS)/sdks/iPhoneOS14.2.sdk
DEBUG = 0
FINALPACKAGE = 1
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PassGen

PassGen_FILES = PassGen.xm
PassGen_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
