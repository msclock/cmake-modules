#[[
This module provides some common tools.
]]

include_guard(GLOBAL)

#[[
Show project version friendly
]]
macro(show_project_version)
  message(STATUS "PROJECT_VRESION finally:${PROJECT_VERSION}")
  message(STATUS "CMAKE_PROJECT_VERSION_MAJOR: ${CMAKE_PROJECT_VERSION_MAJOR}")
  message(STATUS "CMAKE_PROJECT_VERSION_MINOR: ${CMAKE_PROJECT_VERSION_MINOR}")
  message(STATUS "CMAKE_PROJECT_VERSION_PATCH: ${CMAKE_PROJECT_VERSION_PATCH}")
  message(STATUS "CMAKE_PROJECT_VERSION_TWEAK: ${CMAKE_PROJECT_VERSION_TWEAK}")
  message(STATUS "CMAKE_PROJECT_VERSION finally:${CMAKE_PROJECT_VERSION}")
endmacro()

#[[
Show vcpkg configurition
]]
macro(show_vcpkg_configuration)
  message(STATUS "VCPKG_HOST_TRIPLET ${VCPKG_HOST_TRIPLET}")
  message(STATUS "VCPKG_INSTALLED_DIR ${VCPKG_INSTALLED_DIR}")
  message(STATUS "VCPKG_TARGET_TRIPLET ${VCPKG_TARGET_TRIPLET}")
  message(STATUS "VCPKG_LIBRARY_LINKAGE ${VCPKG_LIBRARY_LINKAGE}")
  message(STATUS "VCPKG_TARGET_IS_WINDOWS ${VCPKG_TARGET_IS_WINDOWS}")
  message(STATUS "VCPKG_TARGET_IS_MINGW ${VCPKG_TARGET_IS_MINGW}")
endmacro()

# Debug configuration
macro(add_debug_macro)
  if(CMAKE_BUILD_TYPE STREQUAL Debug)
    add_definitions(-D_DEBUG)
    message(STATUS "Ensure _DEBUG is defined for Debug configuration")
  endif()
endmacro()

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
    cmake_path(IS_RELATIVE _include_dir _is_relative)
    if(_is_relative)
      set(_include_dir "${CMAKE_CURRENT_SOURCE_DIR}/${include_dir}")
    endif()
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
