set (SOURCES gstedgedetect.c)
    
set (noinst_HEADERS gstedgedetect.h)

include_directories (AFTER ..)

add_library (libgstedgedetect STATIC ${SOURCES} ${noinst_HEADERS})