#[[
This module provides some common tools.
]]

include_guard(GLOBAL)
include(${CMAKE_CURRENT_LIST_DIR}/InstallCopyright.cmake)

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
  INCLUDES - The include directories to install. (optional)
  INCLUDE_FILES - The include files to install. (optional)
  TARGETS - The targets to pack. (required)
  DEPENDENCIES - The dependencies to check in config file. (required)

Note:

  Includes from sources can be installed by PUBLIC_HEADER using set_target_properties
  which flattens the hierarchy and puts the header files into the same directory. So
  the recommended way it to use INCLUDES or INCLUDE_FILES.
  see https://stackoverflow.com/questions/54271925/how-to-configure-cmakelists-txt-to-install-public-headers-of-a-shared-library

Example:

  add_library(header INTERFACE)
  target_include_interface_directories(header ${CMAKE_CURRENT_SOURCE_DIR}/include)
  target_link_libraries(header INTERFACE absl::log)
  set_target_properties(header PROPERTIES PUBLIC_HEADER "${public_headers}")
  install_target(
    NAME
    header
    VERSION
    ${CMAKE_PROJECT_VERSION}
    INCLUDES
    ${CMAKE_CURRENT_SOURCE_DIR}/include/ # install subdirectories with /
    TARGETS
    header
    DEPENDENCIES
    "absl:log")

]]
function(install_target)
  set(_opts)
  set(_single_opts NAME VERSION COMPATIBILITY CONFIGURE_PACKAGE_CONFIG_FILE)
  set(_multi_opts TARGETS INCLUDES INCLUDE_FILES DEPENDENCIES LICENSE_FILE_LIST)
  cmake_parse_arguments(PARSE_ARGV 0 arg "${_opts}" "${_single_opts}"
                        "${_multi_opts}")

  include(GNUInstallDirs)
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

  if(arg_INCLUDES)
    install(DIRECTORY ${arg_INCLUDES}
            DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${arg_NAME})
  endif()

  if(arg_INCLUDE_FILES)
    install(FILES ${arg_INCLUDE_FILES}
            DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${arg_NAME})
  endif()

  if(arg_LICENSE_FILE_LIST)
    install_copyright(FILE_LIST ${arg_LICENSE_FILE_LIST} DESTINATION
                      share/${arg_NAME})
  endif()

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

#[[
A function to provide a target to uninstall things from the command `cmake install`.

It will create a file ``cmake_uninstall.cmake`` in the build directory and add a
custom target ``uninstall`` (or ``UNINSTALL`` on Visual Studio and Xcode) that
will remove the files installed by your package (using ``install_manifest.txt``).
See also https://gitlab.kitware.com/cmake/community/wikis/FAQ#can-i-do-make-uninstall-with-cmake

]]
function(create_uninstall_target)
  # AddUninstallTarget works only when included in the main CMakeLists.txt
  if(NOT "${CMAKE_CURRENT_BINARY_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")
    return()
  endif()

  # The name of the target is uppercase in MSVC and Xcode (for coherence with
  # the other standard targets)
  if("${CMAKE_GENERATOR}" MATCHES "^(Visual Studio|Xcode)")
    set(_uninstall "UNINSTALL")
  else()
    set(_uninstall "uninstall")
  endif()

  # If target is already defined don't do anything
  if(TARGET ${_uninstall})
    return()
  endif()

  set(uninstall_script_config
      "if(NOT EXISTS \"@CMAKE_BINARY_DIR@/install_manifest.txt\")
  message(FATAL_ERROR \"Cannot find install manifest: @CMAKE_BINARY_DIR@/install_manifest.txt\")
endif()

file(READ \"@CMAKE_BINARY_DIR@/install_manifest.txt\" files)
string(REGEX REPLACE \"\\n\" \"\;\" files \"\${files}\")
foreach(file \${files})
  message(STATUS \"Uninstalling \$ENV{DESTDIR}\${file}\")
  if(IS_SYMLINK \"\$ENV{DESTDIR}\${file}\" OR EXISTS \"\$ENV{DESTDIR}\${file}\")
    exec_program(
      \"@CMAKE_COMMAND@\" ARGS \"-E remove \\\"\$ENV{DESTDIR}\${file}\\\"\"
      OUTPUT_VARIABLE rm_out
      RETURN_VALUE rm_retval
      )
    if(NOT \"\${rm_retval}\" STREQUAL 0)
      message(FATAL_ERROR \"Problem when removing \$ENV{DESTDIR}\${file}\")
    endif()
  else(IS_SYMLINK \"\$ENV{DESTDIR}\${file}\" OR EXISTS \"\$ENV{DESTDIR}\${file}\")
    message(STATUS \"File \$ENV{DESTDIR}\${file} does not exist.\")
  endif()
endforeach()
")

  set(_uninstall_file "cmake_uninstall.cmake")
  file(WRITE "${CMAKE_BINARY_DIR}/${_uninstall_file}.in"
       ${uninstall_script_config})

  set(_comment COMMENT "Uninstall the project...")

  # uninstall target
  if(NOT TARGET ${_uninstall})
    configure_file("${CMAKE_BINARY_DIR}/${_uninstall_file}.in"
                   "${CMAKE_BINARY_DIR}/${_uninstall_file}" IMMEDIATE @ONLY)

    add_custom_target(
      ${_uninstall}
      ${_comment}
      COMMAND ${CMAKE_COMMAND} -P ${CMAKE_BINARY_DIR}/${_uninstall_file}
      BYPRODUCTS uninstall_byproduct)
    set_property(SOURCE uninstall_byproduct PROPERTY SYMBOLIC 1)

    set_property(TARGET ${_uninstall} PROPERTY FOLDER "CMakePredefinedTargets")
  endif()

endfunction()
