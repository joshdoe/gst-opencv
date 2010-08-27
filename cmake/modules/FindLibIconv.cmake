file(TO_CMAKE_PATH "$ENV{LIBICONV_DIR}" TRY1_DIR)
file(TO_CMAKE_PATH "${LIBICONV_DIR}" TRY2_DIR)
file(GLOB LIBICONV_DIR ${TRY1_DIR} ${TRY2_DIR})
set (LIBICONV_DIR "${LIBICONV_DIR}" CACHE PATH "Directory containing iconv.h")

find_path(LIBICONV_INCLUDE_DIRS iconv.h
                               PATHS ${LIBICONV_DIR}/include /usr/local/include /usr/include
                               ENV INCLUDE DOC "Directory containing iconv.h include file")

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LibIconv DEFAULT_MSG  LIBICONV_INCLUDE_DIRS)