#[[
This module contains default modules and settings that can be used by all projects.
]]

include_guard(GLOBAL)

# Prevent the module from being used in the wrong location
if(NOT CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
  message(FATAL_ERROR "This module should be in the project root directory")
endif()

include(${CMAKE_CURRENT_LIST_DIR}/configure/Default.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/build/Default.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/test/Default.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/install/Default.cmake)

add_debug_macro()

create_uninstall_target()
