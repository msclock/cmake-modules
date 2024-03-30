#[[
Common tools
]]

include_guard(GLOBAL)

include(CheckCXXSourceCompiles)

#[[
Check that the variable with given name is defined。

Example:

  # This will check if the variable CMAKE_BUILD_TYPE is defined. If it is not defined, it will print an error message and exit the script.
  check_variable(CMAKE_BUILD_TYPE)

]]
macro(require_variable variable_name)
  message(DEBUG "Checking required variable ${variable_name}")

  if("${${variable_name}}" STREQUAL "")
    message(FATAL_ERROR "The variable ${variable_name} is required")
  endif()
endmacro()

#[[
Append value to the following variables.

Example:

  # This will append "-fno-omit-frame-pointer" to CMAKE_C_FLAGS and CMAKE_CXX_FLAGS.
  append_variable("-fno-omit-frame-pointer" CMAKE_C_FLAGS CMAKE_CXX_FLAGS)

]]
function(append_variable value)
  message(DEBUG "Append ${value} to ${ARGN}")

  foreach(_target ${ARGN})
    set(${_target}
        "${${_target}} ${value}"
        PARENT_SCOPE)
  endforeach(_target)
endfunction()

#[[
Append value to the following variables.

Example:

  # This will append "-fno-omit-frame-pointer" to CMAKE_C_FLAGS and CMAKE_CXX_FLAGS without quotes syntax.
  append_variable_quoteless(-fno-omit-frame-pointer CMAKE_C_FLAGS CMAKE_CXX_FLAGS)

]]
function(append_variable_quoteless value)
  message(DEBUG "Append ${value} to ${ARGN} quotelessly")

  foreach(_target ${ARGN})
    set(${_target}
        ${${_target}} ${value}
        PARENT_SCOPE)
  endforeach(_target)
endfunction()

#[[
Check if certain flags are available in the C/C++ compiler

Usage:
  check_flags_available(return_var flags)
Parameters:
  return_var: The variable to store the result of flag availability check
  flags: The flags to be checked for availability
]]
function(check_flags_available return_var flags)
  # TODO support other compilers
  include(CheckCXXCompilerFlag)
  check_cxx_compiler_flag("${flags}" ${return_var})
endfunction()

#[[
Check if certain flags are available in the CXX compiler, if true, append
the flags to the specified variable and print a message, otherwise, print
a warning or error message.

Example:

  # This will check if the flag "-fno-omit-frame-pointer" is available in the
  # C++ compiler, and if it is, it will append it to CMAKE_C_FLAGS and CMAKE_CXX_FLAGS.
  # If it is not available, it will print an error message and exit.
  check_and_append_flags(FLAGS "-fno-omit-frame-pointer" TARGETS CMAKE_C_FLAGS CMAKE_CXX_FLAGS REQUIRED)
]]
function(check_and_append_flag)
  set(_opts REQUIRED)
  set(_single_opts FLAGS)
  set(_multi_opts TARGETS)
  cmake_parse_arguments(PARSE_ARGV 0 "arg" "${_opts}" "${_single_opts}"
                        "${_multi_opts}")

  message(DEBUG "Checking flags ${arg_FLAGS} for ${arg_TARGETS}")
  string(REGEX REPLACE "[ ]" "&&" san_available "${arg_FLAGS}")
  unset(${san_available} CACHE)
  check_flags_available(${san_available} "${arg_FLAGS}")

  if(${${san_available}})
    message(DEBUG "  Appending ${arg_FLAGS} to ${arg_TARGETS}")

    foreach(_target ${arg_TARGETS})
      set(${_target}
          "${${_target}} ${arg_FLAGS}"
          PARENT_SCOPE)
    endforeach()
  else()
    if(arg_REQUIRED)
      message(
        FATAL_ERROR
          "The flag ${arg_FLAGS} is required but not available for ${CMAKE_CXX_COMPILER}"
      )
    else()
      message(
        DEBUG
        "The flag ${arg_FLAGS} is not available for ${CMAKE_CXX_COMPILER}, skipping"
      )
    endif()
  endif()
endfunction()

#[[
Add compile options, link options, definitions, and link targets to a target.

Example:

  # This will add compile options "-fno-omit-frame-pointer" to the target "my_target".
  options_target(my_target FLAGS "-fno-omit-frame-pointer")
]]
function(options_target target)
  set(_opts)
  set(_single_opts)
  set(_multi_opts FLAGS LINKS DEFINITIONS LINK_TARGETS)
  cmake_parse_arguments(PARSE_ARGV 0 "arg" "${_opts}" "${_single_opts}"
                        "${_multi_opts}")

  if(arg_FLAGS)
    target_compile_options(${target} PRIVATE ${arg_FLAGS})
  endif()

  if(arg_LINKS)
    target_link_options(${target} PRIVATE ${arg_LINKS})
  endif()

  if(arg_DEFINITIONS)
    target_compile_definitions(${target} PRIVATE ${arg_DEFINITIONS})
  endif()
endfunction()
