if (NOT LIBICONV_DIR)
    set (LIBICONV_DIR "" CACHE PATH "Directory containing iconv.h")
endif ()

file(TO_CMAKE_PATH "$ENV{LIBICONV_DIR}" TRY1_DIR)
file(TO_CMAKE_PATH "${LIBICONV_DIR}" TRY2_DIR)
file(GLOB LIBICONV_DIR ${TRY1_DIR} ${TRY2_DIR})

find_path(LIBICONV_INCLUDE_DIR iconv.h
                               PATHS ${LIBICONV_DIR}/include /usr/local/include /usr/include
                               ENV INCLUDE DOC "Directory containing iconv.h include file")
mark_as_advanced (LIBICONV_INCLUDE_DIR)

if (LIBICONV_INCLUDE_DIR)
  set(LIBICONV_FOUND TRUE)
endif (LIBICONV_INCLUDE_DIR)
