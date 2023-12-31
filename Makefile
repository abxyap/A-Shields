TARGET = iphone:12.2:12.2
ARCHS = arm64 arm64e
PREFIX="/Library/Developer/TheosToolchains/Xcode11.xctoolchain/usr/bin/"

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AShields
AShields_FILES = Tweak.xm ASScanner.m ASWindow.m ASViewController.m
AShields_FRAMEWORKS = LocalAuthentication
AShields_PRIVATE_FRAMEWORKS = SpringBoardUIServices Preferences
AShields_LIBRARIES = mryipc colorpicker

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += ashieldsprefs
# SUBPROJECTS += ashieldsappsupport
include $(THEOS_MAKE_PATH)/aggregate.mk
