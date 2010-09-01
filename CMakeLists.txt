cmake_minimum_required (VERSION "2.8.0")

list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/modules)

project (gst-opencv)

set(GSTREAMER_DEBUG true)
find_package (Gstreamer 0.10.29 REQUIRED core base)
find_package (Glib2 REQUIRED)
find_package (OpenCV REQUIRED)

# conditional required packages
include (CheckIncludeFiles)
CHECK_INCLUDE_FILES ("${GSTREAMER_INCLUDE_DIRS}/gst/gstconfig.h" GST_DISABLE_XML)
if (NOT GST_DISABLE_XML)
  find_package (LibXml2)
  find_package (LibIconv)
  include_directories (AFTER
    ${LIBXML2_INCLUDE_DIRS}
    ${LIBICONV_INCLUDE_DIRS})
endif (NOT GST_DISABLE_XML)

# includes common to entire package
include_directories (
  .
  ${GSTREAMER_INCLUDE_DIRS}
  ${GLIB2_INCLUDE_DIRS}
  ${OPENCV_INCLUDE_DIRS} )

if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  file (TO_CMAKE_PATH "${GSTREAMER_INCLUDE_DIRS}/../.." PREFIX)
  set (CMAKE_INSTALL_PREFIX
    ${PREFIX} CACHE PATH "Directory to install plugins, under lib/gstreamer-0.10" FORCE)
endif (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)

add_subdirectory (src)
