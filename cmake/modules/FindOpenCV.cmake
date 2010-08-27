###########################################################
#                  Find OpenCV Library
# See http://sourceforge.net/projects/opencvlibrary/
#----------------------------------------------------------
#
## 1: Setup:
# The following variables are optionally searched for defaults
#  OPENCV_DIR:            Base directory of OpenCv tree to use.
#
# If OPENCV_DIR is not set, then pkg-config (if available) will be
# used to try and find OpenCV. This of course means you can set the
# environment variable PKG_CONFIG_PATH to point to the directory
# containing opencv.pc.
#
## 2: Variable
# The following are set after configuration is done:
#
#  OPENCV_FOUND
#  OPENCV_LIBRARIES
#  OPENCV_INCLUDE_DIRS
#  OPENCV_VERSION
#
## 3: Version
#
# 2010/08/25 Josh Doe, Use pkg-config OPENCV_DIR is not set.
# 2010/04/07 Benoit Rat, Correct a bug when OpenCVConfig.cmake is not found.
# 2010/03/24 Benoit Rat, Add compatibility for when OpenCVConfig.cmake is not found.
# 2010/03/22 Benoit Rat, Creation of the script.
#
#
# tested with:
# - OpenCV 2.1:  MinGW, MSVC2008, Unix Makefiles (Linux)
# - OpenCV 2.0:  MinGW, MSVC2008, GCC4
#
#
## 4: Licence:
#
# LGPL 2.1 : GNU Lesser General Public License Usage
# Alternatively, this file may be used under the terms of the GNU Lesser
# General Public License version 2.1 as published by the Free Software
# Foundation and appearing in the file LICENSE.LGPL included in the
# packaging of this file.  Please review the following information to
# ensure the GNU Lesser General Public License version 2.1 requirements
# will be met: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
#
#----------------------------------------------------------

# see if variables are in the cache
if(OPENCV_INCLUDE_DIRS AND OPENCV_LIBRARIES)
  set(OpenCV_FIND_QUIETLY TRUE)
endif(OPENCV_INCLUDE_DIRS AND OPENCV_LIBRARIES)

file(TO_CMAKE_PATH "$ENV{OPENCV_DIR}" TRY1_DIR)
file(TO_CMAKE_PATH "${OPENCV_DIR}" TRY2_DIR)
file(GLOB OPENCV_DIR ${TRY1_DIR} ${TRY2_DIR})
set(OPENCV_DIR ${OPENCV_DIR} CACHE STRING "Directory containing OpenCV")

##====================================================
## Find OpenCV libraries
##----------------------------------------------------

# if OPENCV_DIR is not defined, then try and find OpenCV with pkg-config
if(NOT EXISTS "${OPENCV_DIR}")
  find_package(PkgConfig)
  if(PKG_CONFIG_FOUND)
    pkg_check_modules(PC_OPENCV QUIET opencv>=2)
    if(PC_OPENCV_FOUND)
      #message(STATUS "DEBUG: OpenCV include directory from pkg-config= ${PC_OPENCV_INCLUDE_DIRS}")
      #message(STATUS "DEBUG: OpenCV link directory from pkg-config= ${PC_OPENCV_LIBRARY_DIRS}")
    endif(PC_OPENCV_FOUND)
  endif(PKG_CONFIG_FOUND)
endif(NOT EXISTS "${OPENCV_DIR}")
 
if(EXISTS "${OPENCV_DIR}" OR PC_OPENCV_FOUND)

  #When its possible to use the Config script use it.
  if(EXISTS "${OPENCV_DIR}/OpenCVConfig.cmake")

    ## Include the standard CMake script
    include("${OPENCV_DIR}/OpenCVConfig.cmake")

    # conform variable names
    #set(OPENCV_FOUND ${OpenCV_FOUND})
    #set(OPENCV_LIBRARIES "${OpenCV_LIBS}")
    set(OPENCV_INCLUDE_DIRS "${OpenCV_INCLUDE_DIR}")
    set(OPENCV_VERSION ${OpenCV_VERSION})

    ## Search for a specific version
    set(CVLIB_SUFFIX "${OpenCV_VERSION_MAJOR}${OpenCV_VERSION_MINOR}${OpenCV_VERSION_PATCH}")

  #Otherwise it try to guess it.
  else(EXISTS "${OPENCV_DIR}/OpenCVConfig.cmake")

    set(OPENCV_LIB_COMPONENTS cxcore cv ml highgui cvaux)
    find_path(OPENCV_INCLUDE_DIRS "cv.h"
      PATHS "${OPENCV_DIR}" PC_OPENCV_INCLUDE_DIRS
      PATH_SUFFIXES "include" "include/opencv" 
      DOC "Directory containing OpenCV header files"
    )

    #Find OpenCV version by looking at cvver.h
    file(STRINGS ${OPENCV_INCLUDE_DIRS}/cvver.h OPENCV_VERSIONS_TMP REGEX "^#define CV_[A-Z]+_VERSION[ \t]+[0-9]+$")
    string(REGEX REPLACE ".*#define CV_MAJOR_VERSION[ \t]+([0-9]+).*" "\\1" OPENCV_VERSION_MAJOR ${OPENCV_VERSIONS_TMP})
    string(REGEX REPLACE ".*#define CV_MINOR_VERSION[ \t]+([0-9]+).*" "\\1" OPENCV_VERSION_MINOR ${OPENCV_VERSIONS_TMP})
    string(REGEX REPLACE ".*#define CV_SUBMINOR_VERSION[ \t]+([0-9]+).*" "\\1" OPENCV_VERSION_PATCH ${OPENCV_VERSIONS_TMP})
    set(OPENCV_VERSION ${OPENCV_VERSION_MAJOR}.${OPENCV_VERSION_MINOR}.${OPENCV_VERSION_PATCH} CACHE STRING "" FORCE)
    set(CVLIB_SUFFIX "${OPENCV_VERSION_MAJOR}${OPENCV_VERSION_MINOR}${OPENCV_VERSION_PATCH}")
  endif(EXISTS "${OPENCV_DIR}/OpenCVConfig.cmake")

  ## Loop over each component to find debug/release versions
  foreach(__CVLIB ${OPENCV_LIB_COMPONENTS})

    # find debug libraries (only on Windows?)
    find_library(OpenCV_${__CVLIB}_LIBRARY_DEBUG
      NAMES ${__CVLIB}${CVLIB_SUFFIX}d
            lib${__CVLIB}${CVLIB_SUFFIX}d
      PATHS ${PC_OPENCV_LIBRARY_DIRS}
            ${OPENCV_DIR}
      PATH_SUFFIXES lib
      NO_DEFAULT_PATH
      DOC "${__CVLIB} shared library (debug)"
    )

    # find release libraries
    find_library(OpenCV_${__CVLIB}_LIBRARY_RELEASE
      NAMES ${__CVLIB}${CVLIB_SUFFIX}
            lib${__CVLIB}${CVLIB_SUFFIX}
            ${__CVLIB}
      PATHS ${PC_OPENCV_LIBRARY_DIRS}
            ${OPENCV_DIR}
      PATH_SUFFIXES lib
      NO_DEFAULT_PATH
      DOC "${__CVLIB} shared library (debug)"
    )

    # Remove the cache value
    set(OpenCV_${__CVLIB}_LIBRARY "" CACHE STRING "" FORCE)

    # both debug/release
    if(OpenCV_${__CVLIB}_LIBRARY_DEBUG AND OpenCV_${__CVLIB}_LIBRARY_RELEASE)
      set(OpenCV_${__CVLIB}_LIBRARY debug ${OpenCV_${__CVLIB}_LIBRARY_DEBUG} optimized ${OpenCV_${__CVLIB}_LIBRARY_RELEASE}  CACHE STRING "" FORCE)
    # only debug
    elseif(OpenCV_${__CVLIB}_LIBRARY_DEBUG)
      set(OpenCV_${__CVLIB}_LIBRARY ${OpenCV_${__CVLIB}_LIBRARY_DEBUG}  CACHE STRING "" FORCE)
    # only release
    elseif(OpenCV_${__CVLIB}_LIBRARY_RELEASE)
      set(OpenCV_${__CVLIB}_LIBRARY ${OpenCV_${__CVLIB}_LIBRARY_RELEASE}  CACHE STRING "" FORCE)
    endif()
	
	mark_as_advanced(OpenCV_${__CVLIB}_LIBRARY OpenCV_${__CVLIB}_LIBRARY_DEBUG OpenCV_${__CVLIB}_LIBRARY_RELEASE)
	
  endforeach(__CVLIB)
  
  set(OPENCV_LIBRARIES ${OpenCV_cxcore_LIBRARY} ${OpenCV_cv_LIBRARY} ${OpenCV_ml_LIBRARY} ${OpenCV_highgui_LIBRARY} ${OpenCV_cvaux_LIBRARY} CACHE STRING "OpenCV libraries")

else(EXISTS "${OPENCV_DIR}" OR PC_OPENCV_FOUND)

  if(NOT OPENCV_FOUND)
    set(ERR_MSG "Please specify OpenCV directory using OPENCV_DIR env. variable")
  endif(NOT OPENCV_FOUND)

endif(EXISTS "${OPENCV_DIR}" OR PC_OPENCV_FOUND)
##====================================================

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(OpenCV DEFAULT_MSG OPENCV_INCLUDE_DIRS OpenCV_cxcore_LIBRARY OpenCV_cv_LIBRARY OpenCV_ml_LIBRARY OpenCV_highgui_LIBRARY OpenCV_cvaux_LIBRARY)
