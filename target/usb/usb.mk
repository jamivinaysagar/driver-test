# Copyright (C) 2012 Timesys Corporation
#
# usb Tests

$(eval $(call SETUP_TARGET_DIRS,usb))

# Test application manifest
usb_SIMPLE_C=testusb
usb_SCRIPT=testusb.sh setup_usbg_m_storage.sh test_usbg_m_storage.sh backing-file test_usbh_m_storage.sh

testusb_CFLAGS='-lpthread'

usb: $(call STANDARD_DEPS,usb)

$(eval $(call SETUP_BUILD_RULES,usb))

# vim:set noexpandtab:
