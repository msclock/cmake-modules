#[[
This module provides tools to handle cmake installations painlessly.
]]

include_guard(GLOBAL)
include(${CMAKE_CURRENT_LIST_DIR}/Runpath.cmake)

#[[
A function to enable installation of dependencies as part of the
 `make install` process.

Arguments:
  TARGETS - a list of installed targets to have dependencies copied for. (required)
  DIRECTORIES - the directories to search dependencies. (required)
  DESTINATION - the runtime directory for those targets (usually `$<IF:$<PLATFORM_ID:Windows>,bin,lib>`).(optional)
  PRE_EXCLUDE_REGEXES - regular expressions to handle results. (optional)
  POST_EXCLUDE_REGEXES - regular expressions to handle results. (optional)
  POST_INCLUDE_REGEXES - regular expressions to handle results. (optional)

Examples:
  set(app ${CMAKE_PROJECT_NAME}_app)

  add_library(shared SHARED shared.cpp)
  add_executable(${app} main.cpp)

  install(
    TARGETS ${app}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})
  install_dependency(
    TARGETS ${app}
    DIRECTORIES /opt/to/dependencies/find/path)

Note:
  This requires CMake 3.14 for policy CMP0087
]]
function(install_dependency)
  if(CMAKE_VERSION VERSION_LESS "3.16")
    message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} require at least CMake 3.16
(current version: ${CMAKE_VERSION})")
  endif()

  set(_opts)
  set(_single_opts DESTINATION)
  set(_multi_opts TARGETS DIRECTORIES PRE_EXCLUDE_REGEXES POST_EXCLUDE_REGEXES
                  POST_INCLUDE_REGEXES)
  cmake_parse_arguments(PARSE_ARGV 0 arg "${_opts}" "${_single_opts}"
                        "${_multi_opts}")

  if(DEFINED arg_UNPARSED_ARGUMENTS)
    message(
      FATAL_ERROR
        "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}"
    )
  endif()

  if(NOT DEFINED arg_DIRECTORIES)
    message(WARNING "DEPENDENIDES DIRECTORIES must be specified")
  endif()

  if(NOT DEFINED arg_DESTINATION)
    set(arg_DESTINATION ${RUNPATH_SHARED_LOCATION})
  endif()

  # Install CODE|SCRIPT allow the use of generator expressions
  cmake_policy(PUSH)
  # set CMP0087 install code for generator-expression
  if(POLICY CMP0048)
    cmake_policy(SET CMP0087 NEW)
  endif()

  if(NOT IS_ABSOLUTE "${arg_DESTINATION}")
    set(arg_DESTINATION "\${CMAKE_INSTALL_PREFIX}/${arg_DESTINATION}")
  endif()

  list(APPEND arg_PRE_EXCLUDE_REGEXES "")
  list(APPEND arg_POST_EXCLUDE_REGEXES "")

  # Include debug shared system libs earlier
  if(CMAKE_BUILD_TYPE STREQUAL Debug)
    if(CMAKE_HOST_SYSTEM_NAME MATCHES [[Windows]])
      list(APPEND arg_POST_INCLUDE_REGEXES ".*d.dll")
    endif()
  endif()

  if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
    # exclude windows API earlier
    list(
      APPEND
      arg_PRE_EXCLUDE_REGEXES
      "api-ms-.*"
      "ext-ms-.*"
      "ieshims.dll"
      "emclient.dll"
      "devicelockhelpers.dll"
      "python*.dll")

    # exclude system dlls directories later
    list(APPEND arg_POST_EXCLUDE_REGEXES "WINDOWS" "system32")
  else()
    # exclude windows API earlier
    list(
      APPEND
      arg_PRE_EXCLUDE_REGEXES
      "ld-linux[\.\-]"
      "libc[\.\-]"
      "libdl[\.\-]"
      "libdrm[\.\-]"
      "libelf[\.\-]"
      "libexpat[\.\-]"
      "libfontconfig[\.\-]"
      "libfreetype[\.\-]"
      "libg[\.\-]"
      "libgcc_s[\.\-]"
      "libGL[\.\-]"
      "libglib[\.\-]"
      "libgthread[\.\-]"
      "lib(ice|ICE)[\.\-]"
      "libnvidia[\.\-]"
      "libpthread[\.\-]"
      "libse(pol|linux)[\.\-]"
      "libSM[\.\-]"
      "libm[\.\-]"
      "librt[\.\-]"
      "libstdc[\+][\+][\.\-]"
      "libX[a-zA-Z0-9]*[\.\-]"
      "libxcb[\.\-]"
      "libutil[\.]"
      "libomp[\.]"
      "libgomp[\.]" # omp lib
      "libpthread[\.]" # pthread lib
      "libpython" # python lib
      "pylibc[\.\-]") # Linux API
  else()
    message(
      FATAL_ERROR "We can not confirm the current platform when installing")
  endif()

  install(CODE "set(arg_DIRECTORIES \"${arg_DIRECTORIES}\")")
  install(CODE "set(arg_PRE_EXCLUDE_REGEXES \"${arg_PRE_EXCLUDE_REGEXES}\")")
  install(CODE "set(arg_POST_EXCLUDE_REGEXES \"${arg_POST_EXCLUDE_REGEXES}\")")
  install(CODE "set(arg_POST_INCLUDE_REGEXES \"${arg_POST_INCLUDE_REGEXES}\")")
  install(CODE "set(arg_DESTINATION \"${arg_DESTINATION}\")")
  foreach(target IN LISTS arg_TARGETS)
    get_target_property(target_type "${target}" TYPE)
    message(STATUS "target_type:${target_type};$<TARGET_FILE_NAME:${target}>")
    if(NOT target_type STREQUAL "INTERFACE_LIBRARY")

      install(CODE "set(target_type \"${target_type}\")")
      install(CODE "set(target \"$<TARGET_FILE:${target}>\")")
      install(
        CODE [[
          set(library_target "")
          set(executable_target "")
          if(target_type STREQUAL "SHARED_LIBRARY")
            set(library_target ${target})
          elseif(target_type STREQUAL "EXECUTABLE")
            set(executable_target ${target})
          endif()
          file(
            GET_RUNTIME_DEPENDENCIES
            EXECUTABLES
              ${executable_target}
            LIBRARIES
              ${library_target}
            RESOLVED_DEPENDENCIES_VAR
              _r_deps
            UNRESOLVED_DEPENDENCIES_VAR
              _u_deps
            CONFLICTING_DEPENDENCIES_PREFIX
              _c_deps
            DIRECTORIES
              ${arg_DIRECTORIES}
            PRE_EXCLUDE_REGEXES
              ${arg_PRE_EXCLUDE_REGEXES}
            POST_EXCLUDE_REGEXES
              ${arg_POST_EXCLUDE_REGEXES}
            POST_INCLUDE_REGEXES
              ${arg_POST_INCLUDE_REGEXES})

          message(STATUS "Resolved dependencies: ${_r_deps}")
          foreach(_file ${_r_deps})
            file(
              INSTALL
              DESTINATION "${arg_DESTINATION}"
              TYPE SHARED_LIBRARY FOLLOW_SYMLINK_CHAIN FILES "${_file}")
          endforeach()

          if(_u_deps)
            message(STATUS "Unresolved dependencies: ${_u_deps}")
            list(LENGTH _u_deps _u_length)
            if("${_u_length}" GREATER 0)
              message(WARNING "Unresolved dependencies detected:${_u_deps}")
            endif()
          endif()

          if(_c_deps)
            message(STATUS "Conflict dependencies: ${_c_deps_FILENAMES}")
            foreach(_filename ${_c_deps_FILENAMES})
              set(_c_file_list ${_c_deps_${_filename}})
              message(STATUS "conflict ${_filename} list ${_c_file_list}")
              foreach(_file ${_c_file_list})
                file(
                  INSTALL
                  DESTINATION "${arg_DESTINATION}"
                  TYPE SHARED_LIBRARY FOLLOW_SYMLINK_CHAIN FILES "${_file}")
              endforeach()
            endforeach()
          endif()
      ]])
    endif()
  endforeach()
  cmake_policy(POP)
endfunction()
