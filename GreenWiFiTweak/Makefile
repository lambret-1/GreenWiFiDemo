ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:16.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = GreenWiFiTweak

GreenWiFiTweak_FILES = Tweak.x
GreenWiFiTweak_CFLAGS = -fobjc-arc
GreenWiFiTweak_FRAMEWORKS = UIKit Foundation CoreFoundation
GreenWiFiTweak_CFLAGS += -I$(THEOS)/include/rootless

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
