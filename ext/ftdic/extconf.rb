require 'mkmf'

have_library('ftdi', 'ftdi_init') or fail "Missing ftdi library"

$CFLAGS << '-Wall -g'

create_makefile('ftdic')

