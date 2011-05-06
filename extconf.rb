require 'mkmf'
$CFLAGS += " -std=gnu99 "
find_library("usb-1.0","libusb_init")
create_makefile('rusb')
