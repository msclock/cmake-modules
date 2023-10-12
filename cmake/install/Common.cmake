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
