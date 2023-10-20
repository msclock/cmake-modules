#[[
Common tools
]]

include_guard(GLOBAL)

#[[
 Check that the variable with given name is defined
]]
macro(require_variable variable_name)
  # MESSAGE(STATUS "Checking variable ${variable_name} required by NDB")
  if("${${variable_name}}" STREQUAL "")
    message(FATAL_ERROR "The variable ${variable_name} is required")
  endif()
endmacro()
