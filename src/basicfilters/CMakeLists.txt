set (SOURCES
  gstcvabsdiffs.c
  gstcvadds.c
  gstcvdilateerode.c
  gstcvdilate.c
  gstcvequalizehist.c
  gstcverode.c
  gstcvfilter2d.c
  gstcvlaplace.c
  gstcvresize.c
  gstcvsmooth.c
  gstcvsobel.c)
    
set (noinst_HEADERS
  gstcvabsdiffs.h
  gstcvadds.h
  gstcvdilateerode.h
  gstcvdilate.h
  gstcvequalizehist.h
  gstcverode.h
  gstcvfilter2d.h
  gstcvlaplace.h
  gstcvresize.h
  gstcvsmooth.h
  gstcvsobel.h)

include_directories (AFTER ..)

add_library (libgstbasicfilters STATIC ${SOURCES} ${noinst_HEADERS})