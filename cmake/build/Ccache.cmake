#[[
Configure ccache optimization for compiling.

Example:

  include(Ccache)

]]

include_guard(GLOBAL)

set(USE_CCACHE
    ON
    CACHE BOOL "use ccache to speed up compiling.")

if(NOT USE_CCACHE)
  message(STATUS "Disable ccache")
  return()
endif()

find_program(
  CCACHE_COMMAND
  NAMES ccache
  DOC "ccache executable")

if(CCACHE_COMMAND)
  message(STATUS "Activate ccache: ${CCACHE_COMMAND}")
  set(CMAKE_C_COMPILER_LAUNCHER "${CCACHE_COMMAND}")
  set(CMAKE_CXX_COMPILER_LAUNCHER "${CCACHE_COMMAND}")

  # set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE ccache)

  # set_property(GLOBAL PROPERTY RULE_LAUNCH_LINK ccache)
else()
  message(WARNING "Disable ccache because of no ccache installed")
endif()
