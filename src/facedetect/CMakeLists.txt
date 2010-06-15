set (SOURCES gstfacedetect.c)
    
set (noinst_HEADERS gstfacedetect.h)

include_directories (AFTER ..)

add_library (libgstfacedetect STATIC ${SOURCES} ${noinst_HEADERS})