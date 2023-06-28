TARGET = iphone:12.2:12.2
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = ashieldsprefs
ashieldsprefs_FILES = $(wildcard *.m)
ashieldsprefs_INSTALL_PATH = /Library/PreferenceBundles
ashieldsprefs_FRAMEWORKS = UIKit LocalAuthentication
ashieldsprefs_PRIVATE_FRAMEWORKS = Preferences MobileWiFi CoreServices
ashieldsprefs_LIBRARIES = colorpicker MobileGestalt

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/ashieldsprefs.plist$(ECHO_END)
