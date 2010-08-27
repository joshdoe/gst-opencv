# GLIB2_INCLUDE_DIRS
# GLIB2_LIBRARIES
# GLIB2_FOUND

# see if values are in cache
if (GLIB2_LIBRARIES AND GLIB2_INCLUDE_DIRS )
  set (Glib2_FIND_QUIETLY TRUE)
endif (GLIB2_LIBRARIES AND GLIB2_INCLUDE_DIRS )

if(NOT EXISTS ${GLIB2_DIR})
  file(TO_CMAKE_PATH "$ENV{GLIB2_DIR}" GLIB2_DIR)
endif(NOT EXISTS ${GLIB2_DIR})
set (GLIB2_DIR "${GLIB2_DIR}" CACHE PATH "Directory containing glib-2 includes and libraries")

# if GLIB2_DIR is not defined, then try and find glib-2 with pkg-config
if(NOT EXISTS "${GLIB2_DIR}")
  find_package(PkgConfig)
  if (PKG_CONFIG_FOUND)
    pkg_check_modules (PC_GLIB2 QUIET glib-2.0>=2)
    if (PC_GLIB2_FOUND)
      #message (STATUS "DEBUG: glib-2.0 include directory = ${PC_GLIB2_INCLUDE_DIRS}")
      #message (STATUS "DEBUG: glib-2.0 link directory = ${PC_GLIB2_LIBRARY_DIRS}")
      
      find_path(Glib_glib_2_INCLUDE_DIR glib.h ${PC_GLIB2_INCLUDE_DIRS} NO_DEFAULT_PATH)
      find_path(Glib_glibconfig_2_INCLUDE_DIR glibconfig.h ${PC_GLIB2_INCLUDE_DIRS} NO_DEFAULT_PATH)
      find_library(Glib_glib_2_LIBRARY glib-2.0 ${PC_GLIB2_LIBRARY_DIRS} NO_DEFAULT_PATH)
      find_library(Glib_gmodule_2_LIBRARY gmodule-2.0 ${PC_GLIB2_LIBRARY_DIRS} NO_DEFAULT_PATH)
      find_library(Glib_gobject_2_LIBRARY gobject-2.0 ${PC_GLIB2_LIBRARY_DIRS} NO_DEFAULT_PATH)
      find_library(Glib_gthread_2_LIBRARY gthread-2.0 ${PC_GLIB2_LIBRARY_DIRS} NO_DEFAULT_PATH)
    endif (PC_GLIB2_FOUND)
  endif (PKG_CONFIG_FOUND)
  
else(NOT EXISTS "${GLIB2_DIR}")

  find_path(Glib_glib_2_INCLUDE_DIR glib.h
    PATHS ${GLIB2_DIR} /usr/local /usr /opt/local
	  PATH_SUFFIXES "" "include" "include/glib-2.0"
    ENV INCLUDE
	  DOC "Directory containing glib.h include file"
  )

  find_path(Glib_glibconfig_2_INCLUDE_DIR glibconfig.h
    PATHS ${GLIB2_DIR} /usr/local /usr /opt/local
    PATH_SUFFIXES "" "include" "include/glib-2.0" "lib" "lib/glib-2.0"
    ENV INCLUDE
    DOC "Directory containing glibconfig.h include file"
  )

  find_library(Glib_glib_2_LIBRARY
    NAMES glib-2.0
    PATHS ${GLIB2_DIR} /usr/local /usr /opt/local
    PATH_SUFFIXES "" "lib" "win32/lib" "bin" "win32/bin"
    ENV LIB
    DOC "glib library to link with"
    NO_SYSTEM_ENVIRONMENT_PATH
  )

  find_library(Glib_gmodule_2_LIBRARY
    NAMES gmodule-2.0
    PATHS ${GLIB2_DIR} /usr/local /usr /opt/local
    PATH_SUFFIXES "lib" "win32/lib" "bin" "win32/bin"
    ENV LIB
    DOC "gmodule library to link with"
    NO_SYSTEM_ENVIRONMENT_PATH
  )

  find_library(Glib_gobject_2_LIBRARY
    NAMES gobject-2.0
    PATHS ${GLIB2_DIR} /usr/local /usr /opt/local
    PATH_SUFFIXES "lib" "win32/lib" "bin" "win32/bin"
    ENV LIB
    DOC "gobject library to link with"
    NO_SYSTEM_ENVIRONMENT_PATH
  )

  find_library(Glib_gthread_2_LIBRARY
    NAMES gthread-2.0
    PATHS ${GLIB2_DIR} /usr/local /usr /opt/local
    PATH_SUFFIXES "lib" "win32/lib" "bin" "win32/bin"
    ENV LIB
    DOC "gthread library to link with"
    NO_SYSTEM_ENVIRONMENT_PATH
  )
endif(NOT EXISTS "${GLIB2_DIR}")

mark_as_advanced (Glib_glib_2_INCLUDE_DIR Glib_glibconfig_2_INCLUDE_DIR)
mark_as_advanced (Glib_glib_2_LIBRARY Glib_gmodule_2_LIBRARY Glib_gobject_2_LIBRARY Glib_gthread_2_LIBRARY)

set(GLIB2_INCLUDE_DIRS ${Glib_glib_2_INCLUDE_DIR} ${Glib_glibconfig_2_INCLUDE_DIR})
list(REMOVE_DUPLICATES GLIB2_INCLUDE_DIRS)
set(GLIB2_INCLUDE_DIRS ${GLIB2_INCLUDE_DIRS} CACHE STRING "glib-2.0 include dirs")
set(GLIB2_LIBRARIES ${Glib_glib_2_LIBRARY} ${Glib_gmodule_2_LIBRARY} ${Glib_gobject_2_LIBRARY} ${Glib_gthread_2_LIBRARY})
list(REMOVE_DUPLICATES GLIB2_LIBRARIES)
set(GLIB2_LIBRARIES ${GLIB2_LIBRARIES} CACHE STRING "glib-2.0 libraries")

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Glib2 DEFAULT_MSG Glib_glib_2_INCLUDE_DIR Glib_glibconfig_2_INCLUDE_DIR Glib_glib_2_LIBRARY Glib_gmodule_2_LIBRARY Glib_gobject_2_LIBRARY Glib_gthread_2_LIBRARY)
