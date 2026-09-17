ARCHS = armv7
TARGET = iphone:clang:6.1:5.1

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = iPad1SystemInfo

iPad1SystemInfo_FILES = main.m AppDelegate.m OverviewViewController.m ProcessesViewController.m SystemMetrics.m
iPad1SystemInfo_FRAMEWORKS = UIKit Foundation
iPad1SystemInfo_CFLAGS = -fno-objc-arc -Wall

include $(THEOS_MAKE_PATH)/application.mk

after-install::
	install.exec "killall -9 iPad1SystemInfo 2>/dev/null || true"
