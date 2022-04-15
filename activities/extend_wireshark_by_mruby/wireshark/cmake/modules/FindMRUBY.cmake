find_path(
  MRUBY_INCLUDE_DIR
  mruby.h
  PATHS "${CMAKE_SOURCE_DIR}/mruby/include"
  NO_DEFAULT_PATH
)

find_library(
  MRUBY_LIBRARY
  NAMES mruby
  PATHS "${CMAKE_SOURCE_DIR}/mruby/build/host"
  PATH_SUFFIXES lib
  NO_DEFAULT_PATH
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
  MRUBY
  REQUIRED_VARS
  MRUBY_LIBRARY
  MRUBY_INCLUDE_DIR
  300
  VERSION_VAR
  300
)

set(MRUBY_LIBRARIES "${MRUBY_LIBRARY}")
set(MRUBY_INCLUDE_DIRS ${MRUBY_INCLUDE_DIR} )
set(MRUBY_DLL_DIR)
set(MRUBY_DLL)

mark_as_advanced(MRUBY_INCLUDE_DIRS MRUBY_LIBRARIES)
