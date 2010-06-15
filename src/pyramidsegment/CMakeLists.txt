set (SOURCES gstpyramidsegment.c)
    
set (noinst_HEADERS gstpyramidsegment.h)

include_directories (AFTER ..)

add_library (libgstpyramidsegment STATIC ${SOURCES} ${noinst_HEADERS})