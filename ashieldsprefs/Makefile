ARCHS = arm64
OS := $(shell uname)
ifeq ($(OS),Darwin)
	TARGET = iphone:11.2:11.2
  ARCHS += arm64e
endif

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = ashieldsprefs
ashieldsprefs_FILES = $(wildcard *.m)
ashieldsprefs_INSTALL_PATH = /Library/PreferenceBundles
ashieldsprefs_FRAMEWORKS = UIKit LocalAuthentication
ashieldsprefs_PRIVATE_FRAMEWORKS = Preferences MobileWiFi
ashieldsprefs_LIBRARIES = applist

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/ashieldsprefs.plist$(ECHO_END)
