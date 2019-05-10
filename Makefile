PACKAGE_VERSION = 1.0.1
TARGET = iphone:clang:11.2:6.0
ARCHS = armv7 arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Bigmoji
Bigmoji_FILES = NSString+CKBigEmoji.m CKBigEmojiBalloonView.m Tweak.xm
Bigmoji_PRIVATE_FRAMEWORKS = ChatKit IMCore

include $(THEOS_MAKE_PATH)/tweak.mk