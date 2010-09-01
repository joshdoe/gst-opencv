# - FindGstreamer.cmake
# This module can find the GStreamer library.
#
# The following variables will be defined:
#   GSTREAMER_FOUND - system has GStreamer
#   GSTREAMER_INCLUDE_DIRS - the GStreamer include directories
#   GSTREAMER_LIBRARIES - the libraries needed to use GStreamer
#
#   GSTREAMER_VERSION - the version of GStreamer found (x.y.z)
#   GSTREAMER_VERSION_MAJOR - the major version of GStreamer
#   GSTREAMER_VERSION_MINOR - the minor version of GStreamer
#   GSTREAMER_VERSION_MICRO - the micro version of GStreamer
#   GSTREAMER_VERSION_NANO - the nano version of GStreamer
#                            (final releases=0, git=1, prerelease=2,3,4,...)
#
# Optional variables you can define prior to calling of the module:
#
#   GSTREAMER_DEBUG - enables verbose debugging of the module
#
# Copyright (c) 2009 Kitware, Inc.
# Copyright (c) 2008-2009 Philip Lowman <philip@yhbt.com>
# Copyright (c) 2006, Tim Beaulen <tbscope@gmail.com>
#
# Redistribution and use is allowed according to the terms of the BSD license.
# For details see the accompanying COPYING-CMAKE-SCRIPTS file.

#==============================================================
# _GSTREAMER_GET_VERSION
# Internal function to parse the version number in gstversion.h
#   _OUT_major = Major version number
#   _OUT_minor = Minor version number
#   _OUT_micro = Micro version number
#   _OUT_nano  = Nano version number
#   _gstversion_hdr = Header file to parse
#==============================================================
function(_GSTREAMER_GET_VERSION _OUT_major _OUT_minor _OUT_micro _OUT_nano _gstversion_hdr)
  file(READ ${_gstversion_hdr} _contents)
  if(_contents)
    string(REGEX REPLACE ".*#define GST_VERSION_MAJOR[ \t(]+([0-9]+).*" "\\1" ${_OUT_major} "${_contents}")
    string(REGEX REPLACE ".*#define GST_VERSION_MINOR[ \t(]+([0-9]+).*" "\\1" ${_OUT_minor} "${_contents}")
    string(REGEX REPLACE ".*#define GST_VERSION_MICRO[ \t(]+([0-9]+).*" "\\1" ${_OUT_micro} "${_contents}")
    string(REGEX REPLACE ".*#define GST_VERSION_NANO[ \t(]+([0-9]+).*" "\\1" ${_OUT_nano} "${_contents}")

    if(NOT ${_OUT_major} MATCHES "[0-9]+")
      message(FATAL_ERROR "Version parsing failed for GST_MAJOR_VERSION!")
    endif()
    if(NOT ${_OUT_minor} MATCHES "[0-9]+")
      message(FATAL_ERROR "Version parsing failed for GST_MINOR_VERSION!")
    endif()
    if(NOT ${_OUT_micro} MATCHES "[0-9]+")
      message(FATAL_ERROR "Version parsing failed for GST_MICRO_VERSION!")
    endif()
    if(NOT ${${_OUT_nano}} MATCHES "[0-9]+")
      message(FATAL_ERROR "Version parsing failed for GST_MICRO_VERSION!")
    endif()

    set(${_OUT_major} ${${_OUT_major}} PARENT_SCOPE)
    set(${_OUT_minor} ${${_OUT_minor}} PARENT_SCOPE)
    set(${_OUT_micro} ${${_OUT_micro}} PARENT_SCOPE)
    set(${_OUT_nano} ${${_OUT_nano}} PARENT_SCOPE)

    if(GSTREAMER_DEBUG)
      message(STATUS "[FindGstreamer.cmake:${CMAKE_CURRENT_LIST_LINE}] "
                     "_GSTREAMER_GET_VERSION( ${${_OUT_major}} ${${_OUT_minor}} ${${_OUT_micro}} ${${_OUT_nano}} ${_gstversion_hdr} )")
    endif()

  else()
    message(FATAL_ERROR "Include file ${_gstversion_hdr} does not exist")
  endif()
endfunction()

#============================================================================
# _GSTREAMER_FIND_INCLUDE_DIR
# Internal function to find GStreamer include directories
#   _OUT_dir = variable to hold directories
#   _lib = module to look for (core, base, controller, etc.)
#============================================================================
function(_GSTREAMER_FIND_INCLUDE_DIR _OUT_dir _lib)

  if(GSTREAMER_DEBUG)
    message(STATUS "[FindGstreamer.cmake:${CMAKE_CURRENT_LIST_LINE}] "
                     "_GSTREAMER_FIND_INCLUDE_DIR( ${_lib} )")
  endif()

  if(${PKG_CONFIG_FOUND})
    if(${_lib} STREQUAL "gstreamer" OR ${_lib} STREQUAL "core")
      set(_mod "gstreamer-0.10")
    else()
      set(_mod "gstreamer-${_lib}-0.10")
    endif()

    pkg_check_modules(PC_GSTREAMER QUIET ${_mod})

    if(GSTREAMER_DEBUG)
      message(STATUS "[FindGstreamer.cmake:${CMAKE_CURRENT_LIST_LINE}] "
                       "${_lib}: pkg-config include dirs: ${PC_GSTREAMER_INCLUDE_DIRS}")
    endif()
  endif()

  find_path(${_OUT_dir} gst/gst.h
    PATHS
      ${GSTREAMER_DIR}/include/gstreamer-0.10
      ${PC_GSTREAMER_INCLUDE_DIRS}
      /usr/include/gstreamer-0.10
      /usr/local/include/gstreamer-0.10
      /opt/include/gstreamer-0.10
      C:/gstreamer/include/gstreamer-0.10
  )

  if(${_OUT_dir})
    
    if(GSTREAMER_DEBUG)
      message(STATUS "[FindGstreamer.cmake:${CMAKE_CURRENT_LIST_LINE}] "
                       "${_lib}: include dir: ${${_OUT_dir}}")
    endif()
    set(GSTREAMER_INCLUDE_DIRS ${GSTREAMER_INCLUDE_DIRS} ${${_OUT_dir}})
    set(GSTREAMER_INCLUDE_DIRS ${GSTREAMER_INCLUDE_DIRS} PARENT_SCOPE)
   
    mark_as_advanced(${_OUT_dir})
  endif()

endfunction()

#============================================================================
# _GSTREAMER_FIND_LIBRARY
# Internal function to find GStreamer libraries
#   _OUT_lib = library module path
#   _lib = library module to find (core, base, controller, interfaces, video)
#============================================================================
function(_GSTREAMER_FIND_LIBRARY _OUT_lib _lib)

  if(GSTREAMER_DEBUG)
    message(STATUS "[FindGstreamer.cmake:${CMAKE_CURRENT_LIST_LINE}] "
                     "_GSTREAMER_FIND_LIBRARY( ${_lib} )")
  endif()

  if(${PKG_CONFIG_FOUND})
    if(${_lib} STREQUAL "gstreamer" OR ${_lib} STREQUAL "core")
      set(_mod "gstreamer-0.10")
    else()
      set(_mod "gstreamer-${_lib}-0.10")
    endif()

    pkg_check_modules(PC_GSTREAMER QUIET ${_mod})
    
    if(GSTREAMER_DEBUG)
      message(STATUS "[FindGstreamer.cmake:${CMAKE_CURRENT_LIST_LINE}] "
                       "${_lib}: pkg-config library dirs: ${PC_GSTREAMER_LIBRARY_DIRS}")
    endif()
  endif()

  if(${_lib} STREQUAL "gstreamer" OR ${_lib} STREQUAL "core")
    set(_lib_list "gstreamer-0.10")
  else()
    set(_lib_list "gst${_lib}-0.10")
  endif()

  find_library(${_OUT_lib}
    NAMES ${_lib_list}
    PATHS 
      ${GSTREAMER_DIR}/lib
      ${PC_GSTREAMER_LIBRARY_DIRS}
  )

  if(${_OUT_lib})
    if(GSTREAMER_DEBUG)
      message(STATUS "[FindGstreamer.cmake:${CMAKE_CURRENT_LIST_LINE}] "
                       "${_lib}: library: ${${_OUT_lib}}")
    endif()
    set(GSTREAMER_LIBRARIES ${GSTREAMER_LIBRARIES} ${${_OUT_lib}} PARENT_SCOPE)
    set(${_OUT_lib} ${${_OUT_lib}} PARENT_SCOPE)
    mark_as_advanced(${_OUT_lib})
  endif()
endfunction(_GSTREAMER_FIND_LIBRARY)

#==========================================================
#
# main()
#

#if(GSTREAMER_INCLUDE_DIRS AND GSTREAMER_LIBRARIES AND GSTREAMER_VERSION)
#  set(GSTREAMER_FOUND true)
#
#  if(GSTREAMER_DEBUG)
#    message(STATUS "[FindGstreamer.cmake:${CMAKE_CURRENT_LIST_LINE}] "
#                     "Variables present in cache, skipping configuration")
#  endif()
#  
#  return()
#endif()

# Initialize variables
set(GSTREAMER_FOUND)
set(GSTREAMER_INCLUDE_DIRS)
set(GSTREAMER_LIBRARIES)


if(NOT Gstreamer_FIND_COMPONENTS)
  # Assume they only want the core
  set(Gstreamer_FIND_COMPONENTS core)
endif()

# Set GStreamer directory from environment variable
if(NOT "${GSTREAMER_DIR}")
  file(TO_CMAKE_PATH "$ENV{GSTREAMER_DIR}" GSTREAMER_DIR)
endif()
set(GSTREAMER_DIR ${GSTREAMER_DIR} CACHE PATH "Directory containing gstreamer")


find_package(PkgConfig)


_GSTREAMER_FIND_INCLUDE_DIR(GSTREAMER_INCLUDE_DIR core)

if(NOT GSTREAMER_INCLUDE_DIR)
  message(FATAL_ERROR "[FindGstreamer.cmake:${CMAKE_CURRENT_LIST_LINE}] "
                      "Failed to find gst.h, try specifying GSTREAMER_DIR")
endif()

_GSTREAMER_GET_VERSION(GSTREAMER_VERSION_MAJOR
                       GSTREAMER_VERSION_MINOR
                       GSTREAMER_VERSION_MICRO
                       GSTREAMER_VERSION_NANO
                       ${GSTREAMER_INCLUDE_DIR}/gst/gstversion.h)
set(GSTREAMER_VERSION ${GSTREAMER_VERSION_MAJOR}.${GSTREAMER_VERSION_MINOR}.${GSTREAMER_VERSION_MICRO}.${GSTREAMER_VERSION_NANO})

# Enforce version request
if(Gstreamer_FIND_VERSION)
  cmake_minimum_required(VERSION 2.6.2)
  set(Gstreamer_FAILED_VERSION_CHECK true)
  if(GSTREAMER_DEBUG)
    message(STATUS "[FindGstreamer.cmake:${CMAKE_CURRENT_LIST_LINE}] "
                   "Searching for version ${Gstreamer_FIND_VERSION}")
  endif()
  
  if(Gstreamer_FIND_VERSION_EXACT)
    if(GSTREAMER_VERSION  VERSION_EQUAL  Gstreamer_FIND_VERSION)
      set(Gstreamer_FAILED_VERSION CHECK false)
    endif()
  else()
    if(GSTREAMER_VERSION  VERSION_EQUAL  Gstreamer_FIND_VERSION OR
       GSTREAMER_VERSION VERSION_GREATER Gstreamer_FIND_VERSION)
      set(Gstreamer_FAILED_VERSION_CHECK false)
    endif()
  endif()

  if(Gstreamer_FAILED_VERSION_CHECK)
    if(Gstreamer_FIND_REQUIRED AND NOT Gstreamer_FIND_QUIETLY)
      if(Gstreamer_FIND_VERSION_EXACT)
        message(FATAL_ERROR "GStreamer version check failed.  Version ${GSTREAMER_VERSION} was found, version ${Gstreamer_FIND_VERSION} is needed exactly.")
      else()
        message(FATAL_ERROR "GStreamer version check failed.  Version ${GSTREAMER_VERSION} was found, at least version ${Gstreamer_FIND_VERSION} is required")
      endif()
    endif()    
    
    # If the version check fails, exit out of the module here
    return()
  endif()
endif()


#
# Find all components
#

foreach(_GSTREAMER_component ${Gstreamer_FIND_COMPONENTS})
  string(TOUPPER ${_GSTREAMER_component} _COMPONENT_UPPER)
  _GSTREAMER_FIND_LIBRARY(GSTREAMER_${_COMPONENT_UPPER}_LIBRARY ${_GSTREAMER_component})
  _GSTREAMER_FIND_INCLUDE_DIR(GSTREAMER_${_COMPONENT_UPPER}_INCLUDE_DIR ${_GSTREAMER_component})
endforeach()
set(GSTREAMER_LIBRARIES ${GSTREAMER_LIBRARIES})

#
# Try to enforce components
#

set(_GSTREAMER_everything_found true)

include(FindPackageHandleStandardArgs)

foreach(_GSTREAMER_component ${Gstreamer_FIND_COMPONENTS})
  string(TOUPPER ${_GSTREAMER_component} _COMPONENT_UPPER)

  find_package_handle_standard_args(GStreamer-${_GSTREAMER_component} "Some or all of the gstreamer libraries were not found."
    GSTREAMER_${_COMPONENT_UPPER}_LIBRARY
    GSTREAMER_${_COMPONENT_UPPER}_INCLUDE_DIR)

  if(NOT GSTREAMER-${_COMPONENT_UPPER}_FOUND)
    set(_GSTREAMER_everything_found false)
  endif()
endforeach()

#
# Determine if we found all required components
#
if(_GSTREAMER_everything_found AND NOT Gstreamer_FAILED_VERSION_CHECK)
  set(GSTREAMER_FOUND true)
  set(GSTREAMER_INCLUDE_DIRS ${GSTREAMER_INCLUDE_DIRS} CACHE STRING "GStreamer include directories")
  set(GSTREAMER_LIBRARIES ${GSTREAMER_LIBRARIES} CACHE STRING "GStreamer libraries")
  set(GSTREAMER_VERSION ${GSTREAMER_VERSION} CACHE STRING "GStreamer version")
else()
  # Unset our variables.
  set(GSTREAMER_FOUND false)
  set(GSTREAMER_VERSION)
  set(GSTREAMER_VERSION_MAJOR)
  set(GSTREAMER_VERSION_MINOR)
  set(GSTREAMER_VERSION_MICRO)
  set(GSTREAMER_VERSION_NANO)
  set(GSTREAMER_INCLUDE_DIRS)
  set(GSTREAMER_LIBRARIES)
endif()

