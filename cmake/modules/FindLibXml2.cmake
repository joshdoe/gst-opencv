if (NOT LIBXML2_DIR)
    set (LIBXML2_DIR "" CACHE PATH "Directory containing libxml")
endif ()

file(TO_CMAKE_PATH "$ENV{LIBXML2_DIR}" TRY1_DIR)
file(TO_CMAKE_PATH "${LIBXML2_DIR}" TRY2_DIR)
file(GLOB LIBXML2_DIR ${TRY1_DIR} ${TRY2_DIR})

find_path(LIBXML2_INCLUDE_DIRS libxml/parser.h
                              PATHS ${LIBXML2_DIR}/include ${LIBXML2_DIR}/include/libxml2 /usr/local/include/libxml2 /usr/include/libxml2
                              ENV INCLUDE DOC "Directory containing libxml/parser.h include file")
mark_as_advanced (LIBXML2_INCLUDE_DIRS)

if (LIBXML2_INCLUDE_DIRS)
  set (LIBXML2_FOUND TRUE)
endif (LIBXML2_INCLUDE_DIRS)

