TARGET = iphone:12.2:12.2
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AShieldsAppSupport

AShieldsAppSupport_FILES = Tweak.x
AShieldsAppSupport_CFLAGS = -fobjc-arc
AShieldsAppSupport_LIBRARIES = mryipc

include $(THEOS_MAKE_PATH)/tweak.mk
