set (SOURCES gsttemplatematch.c)
    
set (noinst_HEADERS gsttemplatematch.h)

include_directories (AFTER ..)

add_library (libgsttemplatematch STATIC ${SOURCES} ${noinst_HEADERS})