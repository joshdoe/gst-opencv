# - Try to find GStreamer
# Once done this will define
#
#  GSTREAMER_FOUND - system has GStreamer
#  GSTREAMER_INCLUDE_DIRS - the GStreamer include directory
#  GSTREAMER_LIBRARIES - the libraries needed to use GStreamer
#  GSTREAMER_DEFINITIONS - Compiler switches required for using GStreamer

# Copyright (c) 2006, Tim Beaulen <tbscope@gmail.com>
#
# Redistribution and use is allowed according to the terms of the BSD license.
# For details see the accompanying COPYING-CMAKE-SCRIPTS file.

# TODO: Other versions --> GSTREAMER_X_Y_FOUND (Example: GSTREAMER_0_8_FOUND and GSTREAMER_0_10_FOUND etc)

IF (GSTREAMER_INCLUDE_DIRS AND GSTREAMER_LIBRARIES AND GSTREAMER_BASE_LIBRARY AND GSTREAMER_INTERFACE_LIBRARY)
   # in cache already
   SET(GStreamer_FIND_QUIETLY TRUE)
ELSE (GSTREAMER_INCLUDE_DIRS AND GSTREAMER_LIBRARIES AND GSTREAMER_BASE_LIBRARY AND GSTREAMER_INTERFACE_LIBRARY)
   SET(GStreamer_FIND_QUIETLY FALSE)
ENDIF (GSTREAMER_INCLUDE_DIRS AND GSTREAMER_LIBRARIES AND GSTREAMER_BASE_LIBRARY AND GSTREAMER_INTERFACE_LIBRARY)

file(TO_CMAKE_PATH "$ENV{GSTREAMER_DIR}" TRY1_DIR)
file(TO_CMAKE_PATH "${GSTREAMER_DIR}" TRY2_DIR)
file(GLOB GSTREAMER_DIR ${TRY1_DIR} ${TRY2_DIR})
SET (GSTREAMER_DIR ${GSTREAMER_DIR} CACHE PATH "Directory containing gstreamer")

IF (NOT WIN32)
   # use pkg-config to get the directories and then use these values
   # in the FIND_PATH() and FIND_LIBRARY() calls
   FIND_PACKAGE(PkgConfig)
   PKG_CHECK_MODULES(PC_GSTREAMER QUIET gstreamer-0.10)
   #MESSAGE(STATUS "DEBUG: GStreamer include directory = ${PC_GSTREAMER_INCLUDE_DIRS}")
   #MESSAGE(STATUS "DEBUG: GStreamer link directory = ${PC_GSTREAMER_LIBRARY_DIRS}")
   SET(GSTREAMER_DEFINITIONS ${PC_GSTREAMER_CFLAGS_OTHER})
ELSE (NOT WIN32)
    IF (NOT GSTREAMER_DIR)
        SET (GSTREAMER_DIR "C:/gstreamer")
    ENDIF (NOT GSTREAMER_DIR)
ENDIF (NOT WIN32)

FIND_PATH(GSTREAMER_INCLUDE_DIRS gst/gst.h
   PATHS
   ${GSTREAMER_DIR}/include/gstreamer-0.10
   ${PC_GSTREAMER_INCLUDEDIR}
   ${PC_GSTREAMER_INCLUDE_DIRS}
   #PATH_SUFFIXES gst
   )

file(STRINGS ${GSTREAMER_INCLUDE_DIRS}/gst/gstversion.h GSTREAMER_VERSION_TMP REGEX "^#define GST_VERSION_[A-Z]+[ \t(]+[0-9]+")
string(REGEX REPLACE ".*#define GST_VERSION_MAJOR[ \t(]+([0-9]+).*" "\\1" GSTREAMER_VERSION_MAJOR ${GSTREAMER_VERSION_TMP})
string(REGEX REPLACE ".*#define GST_VERSION_MINOR[ \t(]+([0-9]+).*" "\\1" GSTREAMER_VERSION_MINOR ${GSTREAMER_VERSION_TMP})
string(REGEX REPLACE ".*#define GST_VERSION_MICRO[ \t(]+([0-9]+).*" "\\1" GSTREAMER_VERSION_MICRO ${GSTREAMER_VERSION_TMP})
string(REGEX REPLACE ".*#define GST_VERSION_NANO[ \t(]+([0-9]+).*" "\\1" GSTREAMER_VERSION_NANO ${GSTREAMER_VERSION_TMP})
set(GSTREAMER_VERSION ${GSTREAMER_VERSION_MAJOR}.${GSTREAMER_VERSION_MINOR}.${GSTREAMER_VERSION_MICRO}.${GSTREAMER_VERSION_NANO} CACHE STRING "" FORCE)


FIND_LIBRARY(GSTREAMER_CORE_LIBRARY NAMES gstreamer-0.10
   PATHS
   ${GSTREAMER_DIR}/lib
   ${PC_GSTREAMER_LIBDIR}
   ${PC_GSTREAMER_LIBRARY_DIRS}
   )

FIND_LIBRARY(GSTREAMER_BASE_LIBRARY NAMES gstbase-0.10
   PATHS
   ${GSTREAMER_DIR}/lib
   ${PC_GSTREAMER_LIBDIR}
   ${PC_GSTREAMER_LIBRARY_DIRS}
   )

FIND_LIBRARY(GSTREAMER_CONTROLLER_LIBRARY NAMES gstcontroller-0.10
   PATHS
   ${GSTREAMER_DIR}/lib
   ${PC_GSTREAMER_LIBDIR}
   ${PC_GSTREAMER_LIBRARY_DIRS}
   )

FIND_LIBRARY(GSTREAMER_INTERFACE_LIBRARY NAMES gstinterfaces-0.10
   PATHS
   ${GSTREAMER_DIR}/lib
   ${PC_GSTREAMER_LIBDIR}
   ${PC_GSTREAMER_LIBRARY_DIRS}
   )

FIND_LIBRARY(GSTREAMER_VIDEO_LIBRARY NAMES gstvideo-0.10
   PATHS
   ${GSTREAMER_DIR}/lib
   ${PC_GSTREAMER_LIBDIR}
   ${PC_GSTREAMER_LIBRARY_DIRS}
   )
   
set(GSTREAMER_LIBRARIES ${GSTREAMER_CORE_LIBRARY} ${GSTREAMER_BASE_LIBRARY} ${GSTREAMER_CONTROLLER_LIBRARY} ${GSTREAMER_INTERFACE_LIBRARY} ${GSTREAMER_VIDEO_LIBRARY})
list(REMOVE_DUPLICATES GSTREAMER_LIBRARIES)
set(GSTREAMER_LIBRARIES ${GSTREAMER_LIBRARIES} CACHE STRING "gstreamer-0.10 libraries")

mark_as_advanced(GSTREAMER_LIBRARIES GSTREAMER_CORE_LIBRARY GSTREAMER_BASE_LIBRARY GSTREAMER_CONTROLLER_LIBRARY GSTREAMER_INTERFACE_LIBRARY GSTREAMER_VIDEO_LIBRARY)
	
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GStreamer DEFAULT_MSG GSTREAMER_INCLUDE_DIRS GSTREAMER_CORE_LIBRARY GSTREAMER_BASE_LIBRARY GSTREAMER_CONTROLLER_LIBRARY GSTREAMER_INTERFACE_LIBRARY GSTREAMER_VIDEO_LIBRARY)
