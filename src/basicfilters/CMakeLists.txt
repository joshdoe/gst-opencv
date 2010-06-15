set (SOURCES
    gstcvdilateerode.c
    gstcvdilate.c
    gstcvequalizehist.c
	gstcverode.c
    gstcvlaplace.c
	gstcvsmooth.c
    gstcvsobel.c)
    
set (noinst_HEADERS
	gstcvdilateerode.h
	gstcvdilate.h
	gstcvequalizehist.h
	gstcverode.h
	gstcvlaplace.h
	gstcvsmooth.h
	gstcvsobel.h)

include_directories (AFTER ..)

add_library (libgstbasicfilters STATIC ${SOURCES} ${noinst_HEADERS})