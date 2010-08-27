set (SOURCES
  gstopencv.c
  gstopencvbasetrans.c
  gstopencvutils.c)
	
set (noinst_HEADERS
  config.h
  gstopencvbasetrans.h
  gstopencvutils.h)
	
add_subdirectory (basicfilters)
add_subdirectory (edgedetect)
add_subdirectory (faceblur)
add_subdirectory (facedetect)
add_subdirectory (pyramidsegment)
add_subdirectory (templatematch)
add_subdirectory (textwrite)

include_directories (AFTER
  .
  basicfilters
  edgedetect
  faceblur
  facedetect
  pyramidsegment
  templatematch
  textwrite)

add_definitions (-DHAVE_CONFIG_H)

add_library (libgstopencv MODULE ${SOURCES} ${noinst_HEADERS})
target_link_libraries (libgstopencv
  ${GLIB2_LIBRARIES}
  ${GSTREAMER_LIBRARIES}
  ${OPENCV_LIBRARIES}
  general libgstbasicfilters
  general libgstedgedetect
  general libgstfaceblur
  general libgstfacedetect
  general libgstpyramidsegment
  general libgsttemplatematch
  general libgsttextwrite)
  
install (TARGETS libgstopencv
  LIBRARY DESTINATION lib/gstreamer-0.10)
 
