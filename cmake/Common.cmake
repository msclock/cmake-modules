#[[
Common tools
]]

include_guard(GLOBAL)

#[[
 Check that the variable with given name is defined
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

  append_variable("-fno-omit-frame-pointer" CMAKE_C_FLAGS)

]]
function(append_variable value)
  message(DEBUG "Append ${value} to ${ARGN}")
  foreach(variable ${ARGN})
    set(${variable}
        "${${variable}} ${value}"
        PARENT_SCOPE)
  endforeach(variable)
endfunction()

#[[
Append value to the following variables.

Example:

  append_variable_quoteless(-fno-omit-frame-pointer CMAKE_C_FLAGS)

]]
function(append_variable_quoteless value)
  message(DEBUG "Append ${value} to ${ARGN} quotelessly")
  foreach(variable ${ARGN})
    set(${variable}
        ${${variable}} ${value}
        PARENT_SCOPE)
  endforeach(variable)
endfunction()
