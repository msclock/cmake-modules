#[[
This module provides some common tools.
]]

include_guard(GLOBAL)

#[[
Show installation directories
]]
macro(show_installation)
  foreach(_p LIB BIN INCLUDE CMAKE)
    file(TO_NATIVE_PATH ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_${_p}DIR} _path)
    message(STATUS "Show ${_p} components installation path: ${_path}")
    unset(_path)
  endforeach()
endmacro()

#[[
A function to add install config rules to target

Arguments:
  NAME - A name as the installation export name. (required)
  VERSION - The target version. Default to "0.0.0". (optional)
  COMPATIBILITY - Compatibility on version. Default to SameMajorVersion. (optional)
  CONFIGURE_PACKAGE_CONFIG_FILE - The file to generate config file. (optional)
  TARGETS - The targets to pack. (required)
  DEPENDENCIES - The dependencies to check in config file. (required)

Example:

  add_library(header INTERFACE)
  target_include_interface_directories(header ${CMAKE_CURRENT_SOURCE_DIR}/include)
  target_link_libraries(header INTERFACE absl::log)
  set_target_properties(header PROPERTIES PUBLIC_HEADER "${public_headers}")
  install_target(
    NAME
    header
    VERSION
    ${PROJECT_VERSION}
    TARGETS
    header
    DEPENDENCIES
    "absl:log")

]]
function(install_target)
  set(_opts)
  set(_single_opts NAME VERSION COMPATIBILITY CONFIGURE_PACKAGE_CONFIG_FILE)
  set(_multi_opts TARGETS DEPENDENCIES)
  cmake_parse_arguments(PARSE_ARGV 0 arg "${_opts}" "${_single_opts}"
                        "${_multi_opts}")

  # Specify rules at install time
  install(
    TARGETS ${arg_TARGETS}
    EXPORT ${arg_NAME}-targets
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}$<$<CONFIG:Debug>:/../debug/lib>
            COMPONENT ${arg_NAME}_runtime
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}$<$<CONFIG:Debug>:/../debug/lib>
            COMPONENT ${arg_NAME}_runtime
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}$<$<CONFIG:Debug>:/../debug/lib>
            COMPONENT ${arg_NAME}_runtime
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${arg_NAME}
                  COMPONENT ${arg_NAME}_development)

  install(
    EXPORT ${arg_NAME}-targets
    FILE ${arg_NAME}-targets.cmake
    NAMESPACE ${arg_NAME}::
    DESTINATION share/${arg_NAME}
    COMPONENT ${arg_NAME}_development)

  if(NOT arg_CONFIGURE_PACKAGE_CONFIG_FILE)

    set(_configure_package_config_file_content
        "#[=======================================================================[.rst:
${arg_NAME}-config.cmake
-------------------

${arg_NAME} cmake module.
This module sets the following variables in your project:

::

   ${arg_NAME}_FOUND - true if ${arg_NAME} found on the system
   ${arg_NAME}_VERSION - ${arg_NAME} version in format Major.Minor.Release
")
    string(
      APPEND
      _configure_package_config_file_content
      "

Exported targets:

::

If ${arg_NAME} is found, this module defines the following :prop_tgt:`IMPORTED`
targets. ::
")
    foreach(_tgt ${arg_TARGETS})
      get_target_property(_target_type "${_tgt}" TYPE)
      string(
        APPEND
        _configure_package_config_file_content
        "
    ${arg_NAME}::${_tgt} - the main ${arg_NAME} ${_target_type} with header & defs attached."
      )
    endforeach()

    string(
      APPEND
      _configure_package_config_file_content
      "


Suggested usage:

::

    find_package(${arg_NAME})
    find_package(${arg_NAME} CONFIG REQUIRED)


The following variables can be set to guide the search for this package:

::

    ${arg_NAME}_DIR - CMake variable, set to directory containing this Config file
    CMAKE_PREFIX_PATH - CMake variable, set to root directory of this package
    PATH - environment variable, set to bin directory of this package
    CMAKE_DISABLE_FIND_PACKAGE_${arg_NAME} - CMake variable, disables find_package(${arg_NAME})
    perhaps to force internal build

#]=======================================================================]
")

    string(
      APPEND
      _configure_package_config_file_content
      "@PACKAGE_INIT@

include(CMakeFindDependencyMacro)
")
    string(APPEND _configure_package_config_file_content "
# Dependency check here")
    foreach(_dep ${arg_DEPENDENCIES})
      string(APPEND _configure_package_config_file_content "
find_dependency(${_dep} REQUIRED)")
    endforeach()

    string(REPLACE ";" " " _tgts "${arg_TARGETS}")
    string(
      APPEND
      _configure_package_config_file_content
      "

include(\"\${CMAKE_CURRENT_LIST_DIR}/${arg_NAME}-targets.cmake\")
check_required_components(${_tgts})
")

    file(WRITE ${CMAKE_BINARY_DIR}/${arg_NAME}/${arg_NAME}-config.cmake.in
         ${_configure_package_config_file_content})
    set(arg_CONFIGURE_PACKAGE_CONFIG_FILE
        ${CMAKE_BINARY_DIR}/${arg_NAME}/${arg_NAME}-config.cmake.in)
  endif()

  include(CMakePackageConfigHelpers)

  configure_package_config_file(
    ${arg_CONFIGURE_PACKAGE_CONFIG_FILE}
    ${CMAKE_CURRENT_BINARY_DIR}/${arg_NAME}-config.cmake
    INSTALL_DESTINATION share/${arg_NAME})

  if(NOT arg_COMPATIBILITY)
    set(arg_COMPATIBILITY SameMajorVersion)
  endif()

  if(NOT arg_VERSION)
    set(arg_VERSION "0.0.0")
  endif()

  write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/${arg_NAME}-config-version.cmake
    VERSION ${arg_VERSION}
    COMPATIBILITY ${arg_COMPATIBILITY})

  install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${arg_NAME}-config.cmake
                ${CMAKE_CURRENT_BINARY_DIR}/${arg_NAME}-config-version.cmake
          DESTINATION share/${arg_NAME})

  # Export from build tree
  export(
    EXPORT ${arg_NAME}-targets
    FILE ${CMAKE_CURRENT_BINARY_DIR}/${arg_NAME}-targets.cmake
    NAMESPACE ${arg_NAME}::)

  export(PACKAGE ${arg_NAME})

  # Generate the usage file
  set(_usage_targets)
  foreach(_target ${arg_TARGETS})
    string(APPEND _usage_targets "${arg_NAME}::${_target} ")
  endforeach()
  string(STRIP ${_usage_targets} _usage_targets)
  set(USAGE_FILE_CONTENT
      "# The package ${arg_NAME} provides the following CMake targets:

   find_package(${arg_NAME} CONFIG REQUIRED)
   target_link_libraries(main PRIVATE ${_usage_targets})
")
  file(WRITE ${CMAKE_BINARY_DIR}/${arg_NAME}/usage ${USAGE_FILE_CONTENT})
  install(FILES ${CMAKE_BINARY_DIR}/${arg_NAME}/usage
          DESTINATION share/${arg_NAME})
  install(CODE "MESSAGE(STATUS \"${USAGE_FILE_CONTENT}\")")

endfunction()
