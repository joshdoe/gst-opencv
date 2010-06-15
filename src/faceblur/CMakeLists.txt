set (SOURCES gstfaceblur.c)
    
set (noinst_HEADERS gstfaceblur.h)

include_directories (AFTER ..)

add_library (libgstfaceblur STATIC ${SOURCES} ${noinst_HEADERS})