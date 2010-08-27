# GLIB2_INCLUDE_DIRS
# GLIB2_LIBRARIES
# GLIB2_FOUND

message (STATUS "Check for glib-2.0")

# see if values are in cache
if (GLIB2_LIBRARIES AND GLIB2_INCLUDE_DIRS )
  set(GLIB2_FOUND TRUE)
elseif (GLIB2_LIBRARIES AND GLIB2_INCLUDE_DIRS )
  set(GLIB2_FOUND FALSE)
endif (GLIB2_LIBRARIES AND GLIB2_INCLUDE_DIRS )

if (NOT GLIB2_DIR)
    set (GLIB2_DIR "" CACHE PATH "Directory containing glib-2 includes and libraries")
endif (NOT GLIB2_DIR)

if (EXISTS "${GLIB2_DIR}")
  file(TO_CMAKE_PATH "$ENV{GLIB2_DIR}" TRY1_DIR)
  file(TO_CMAKE_PATH "${GLIB2_DIR}" TRY2_DIR)
  file(GLOB GLIB2_DIR ${TRY1_DIR} ${TRY2_DIR})

  find_path(Glib_glib_2_INCLUDE_DIR glib.h
                                    PATHS ${GLIB2_DIR}/include ${GLIB2_DIR}/include/glib-2.0 /usr/local/include/glib-2.0 /usr/include/glib-2.0 /opt/local/include/glib-2.0
                                    ENV INCLUDE DOC "Directory containing glib.h include file")
  mark_as_advanced (Glib_glib_2_INCLUDE_DIR)

  find_path(Glib_glibconfig_2_INCLUDE_DIR glibconfig.h
                                          PATHS ${GLIB2_DIR}/include ${GLIB2_DIR}/include/glib-2.0 ${GLIB2_DIR}/lib/include ${GLIB2_DIR}/lib/glib-2.0/include /usr/local/include/glib-2.0 /usr/include/glib-2.0 /usr/lib/glib-2.0/include /usr/local/lib/glib-2.0/include /opt/local/lib/glib-2.0/include
                                          ENV INCLUDE DOC "Directory containing glibconfig.h include file")
  mark_as_advanced (Glib_glibconfig_2_INCLUDE_DIR)

  find_library(Glib_glib_2_LIBRARY NAMES glib-2.0
                                   PATHS ${GLIB2_DIR}/bin ${GLIB2_DIR}/win32/bin ${GLIB2_DIR}/lib ${GLIB2_DIR}/win32/lib /usr/local/lib /usr/lib /opt/local/lib
                                   ENV LIB
                                   DOC "glib library to link with"
                                   NO_SYSTEM_ENVIRONMENT_PATH)
  mark_as_advanced (Glib_glib_2_LIBRARY)

  find_library(Glib_gmodule_2_LIBRARY NAMES gmodule-2.0
                                      PATHS ${GLIB2_DIR}/bin ${GLIB2_DIR}/win32/bin ${GLIB2_DIR}/lib ${GLIB2_DIR}/win32/lib /usr/local/lib /usr/lib /opt/local/lib
                                      ENV LIB
                                      DOC "gmodule library to link with"
                                      NO_SYSTEM_ENVIRONMENT_PATH)
  mark_as_advanced (Glib_gmodule_2_LIBRARY)

  find_library(Glib_gobject_2_LIBRARY NAMES gobject-2.0
                                      PATHS ${GLIB2_DIR}/bin ${GLIB2_DIR}/win32/bin ${GLIB2_DIR}/lib ${GLIB2_DIR}/win32/lib /usr/local/lib /usr/lib /opt/local/lib
                                      ENV LIB
                                      DOC "gobject library to link with"
                                      NO_SYSTEM_ENVIRONMENT_PATH)
  mark_as_advanced (Glib_gobject_2_LIBRARY)

  find_library(Glib_gthread_2_LIBRARY NAMES gthread-2.0
                                      PATHS ${GLIB2_DIR}/bin ${GLIB2_DIR}/win32/bin ${GLIB2_DIR}/lib ${GLIB2_DIR}/win32/lib /usr/local/lib /usr/lib /opt/local/lib
                                      ENV LIB
                                      DOC "gthread library to link with"
                                      NO_SYSTEM_ENVIRONMENT_PATH)
  mark_as_advanced (Glib_gthread_2_LIBRARY)

  if (Glib_glib_2_INCLUDE_DIR AND Glib_glibconfig_2_INCLUDE_DIR AND Glib_glib_2_LIBRARY AND Glib_gmodule_2_LIBRARY AND Glib_gobject_2_LIBRARY AND Glib_gthread_2_LIBRARY)
    set(GLIB2_INCLUDE_DIRS ${Glib_glib_2_INCLUDE_DIR} ${Glib_glibconfig_2_INCLUDE_DIR})
    list(REMOVE_DUPLICATES GLIB2_INCLUDE_DIRS)
    set(GLIB2_LIBRARIES ${Glib_glib_2_LIBRARY} ${Glib_gmodule_2_LIBRARY} ${Glib_gobject_2_LIBRARY} ${Glib_gthread_2_LIBRARY})
    list(REMOVE_DUPLICATES GLIB2_LIBRARIES)
    set(GLIB2_FOUND TRUE)
  endif (Glib_glib_2_INCLUDE_DIR AND Glib_glibconfig_2_INCLUDE_DIR AND Glib_glib_2_LIBRARY AND Glib_gmodule_2_LIBRARY AND Glib_gobject_2_LIBRARY AND Glib_gthread_2_LIBRARY)

else (EXISTS "${GLIB2_DIR}")
  find_package(PkgConfig)
  if (PKG_CONFIG_FOUND)
    pkg_check_modules (GLIB2 QUIET glib-2.0>=2)
    if (GLIB2_FOUND)
      #message (STATUS "DEBUG: glib-2.0 include directory = ${GLIB2_INCLUDE_DIRS}")
      #message (STATUS "DEBUG: glib-2.0 link directory = ${GLIB2_LIBRARY_DIRS}")
    endif (GLIB2_FOUND)
  endif (PKG_CONFIG_FOUND)
 
  if (NOT GLIB2_FOUND)
    set (ERR_MSG "Please specify glib-2.0 directory using Glib_DIR env. variable")
  endif (NOT GLIB2_FOUND)
endif (EXISTS "${GLIB2_DIR}")

if(GLIB2_FOUND)
  message (STATUS "Check for glib-2.0: found")
else(GLIB2_FOUND)
  # make FIND_PACKAGE friendly
  if(NOT Glib2_FIND_QUIETLY)
        if(Glib2_FIND_REQUIRED)
          message(FATAL_ERROR "glib-2.0 required but some headers or libs not found. ${ERR_MSG}")
        else(Glib2_FIND_REQUIRED)
          message(STATUS "WARNING: glib-2.0 was not found. ${ERR_MSG}")
        endif(Glib2_FIND_REQUIRED)
  endif(NOT Glib2_FIND_QUIETLY)
endif(GLIB2_FOUND)