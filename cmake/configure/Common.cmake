#[[
This module provides some common tools.
]]

include_guard(GLOBAL)

#[[
Show project version friendly
]]
macro(show_project_version)
  message(STATUS "CMAKE_PROJECT_VERSION finally:${CMAKE_PROJECT_VERSION}")
  message(STATUS "CMAKE_PROJECT_VERSION_MAJOR: ${CMAKE_PROJECT_VERSION_MAJOR}")
  message(STATUS "CMAKE_PROJECT_VERSION_MINOR: ${CMAKE_PROJECT_VERSION_MINOR}")
  message(STATUS "CMAKE_PROJECT_VERSION_PATCH: ${CMAKE_PROJECT_VERSION_PATCH}")
  message(STATUS "CMAKE_PROJECT_VERSION_TWEAK: ${CMAKE_PROJECT_VERSION_TWEAK}")
endmacro()

#[[
Show vcpkg configurition
]]
function(show_vcpkg_configuration)
  # Print all vcpkg variables
  get_cmake_property(_vars VARIABLES)
  foreach(_var IN LISTS _vars)
    if(_var MATCHES "^VCPKG_")
      message(STATUS "${_var} ${${_var}}")
    endif()
  endforeach()
endfunction()

#[[
Add definition _DEBUG with config type Debug
]]
function(add_debug_macro)
  if(CMAKE_BUILD_TYPE STREQUAL Debug)
    add_definitions(-D_DEBUG)
    message(DEBUG "Ensure _DEBUG is defined for Debug configuration")
  endif()
endfunction()

#[[
A function to include directories to target.

Example:

  add_executable(main main.cpp)
  target_include_interface_directories(main include1 include2)

]]
function(target_include_interface_directories target)
  set(_includes)
  foreach(_include_dir ${ARGN})
    # Make include_dir absolute
    cmake_path(ABSOLUTE_PATH _include_dir BASE_DIRECTORY
               ${CMAKE_CURRENT_SOURCE_DIR})
    list(APPEND _includes $<BUILD_INTERFACE:${_include_dir}>)
  endforeach()

  list(APPEND _includes $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)
  # Include the interface directory
  get_target_property(_has_source_files ${target} SOURCES)
  if(NOT _has_source_files)
    target_include_directories(${target} INTERFACE ${_includes})
  else()
    target_include_directories(${target} PUBLIC ${_includes})
  endif()
endfunction()
