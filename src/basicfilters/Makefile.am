noinst_LTLIBRARIES = libgstbasicfilters.la

# sources used to compile this plug-in
libgstbasicfilters_la_SOURCES = \
    gstcvabsdiffs.c \
    gstcvadds.c \
    gstcvands.c \
    gstcvcmps.c \
    gstcvdilateerode.c \
    gstcvdilate.c \
    gstcverode.c \
    gstcvequalizehist.c \
    gstcvfilter2d.c \
    gstcvlaplace.c \
    gstcvresize.c \
    gstcvsmooth.c \
    gstcvsobel.c

# flags used to compile this pyramidsegment
# add other _CFLAGS and _LIBS as needed
libgstbasicfilters_la_CFLAGS = $(GST_CFLAGS) $(OPENCV_CFLAGS) -I..
libgstbasicfilters_la_LIBADD = $(GST_LIBS) $(OPENCV_LIBS)
libgstbasicfilters_la_LDFLAGS = $(GST_PLUGIN_LDFLAGS)

# headers we need but don't want installed
noinst_HEADERS = 
  gstcvabsdiffs.h \
  gstcvadds.h \
  gstcvands.h \
  gstcvcmps.h \
  gstcvdilateerode.h \
  gstcvdilate.h \
  gstcvequalizehist.h \
  gstcverode.h \
  gstcvfilter2d.h \
  gstcvlaplace.h \
  gstcvresize.h \
  gstcvsmooth.h \
  gstcvsobel.h
