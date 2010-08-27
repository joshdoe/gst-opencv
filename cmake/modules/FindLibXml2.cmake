if(NOT EXISTS ${LIBXML2_DIR})
  file(TO_CMAKE_PATH "$ENV{LIBXML2_DIR}" LIBXML2_DIR)
endif(NOT EXISTS ${LIBXML2_DIR})
set(LIBXML2_DIR "${LIBXML2_DIR}" CACHE PATH "Directory containing libxml")

find_path(LIBXML2_INCLUDE_DIRS libxml/parser.h
                              PATHS ${LIBXML2_DIR}/include ${LIBXML2_DIR}/include/libxml2 /usr/local/include/libxml2 /usr/include/libxml2
                              ENV INCLUDE DOC "Directory containing libxml/parser.h include file")
mark_as_advanced(LIBXML2_INCLUDE_DIRS)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LibXml2 DEFAULT_MSG  LIBXML2_INCLUDE_DIRS)
