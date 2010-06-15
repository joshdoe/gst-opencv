set (SOURCES gsttextwrite.c)
    
set (noinst_HEADERS gsttextwrite.h)

include_directories (AFTER ..)

add_library (libgsttextwrite STATIC ${SOURCES} ${noinst_HEADERS})