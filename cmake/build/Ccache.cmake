#[[
Configure ccache optimization for compiling cache

Example:

  include(Ccache)

]]
macro(ccache_enable)
  find_program(CCACHE_PROGRAM ccache)
  if(CCACHE_PROGRAM)
    message(STATUS "Enable ccache")
    set(CMAKE_C_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
    set(CMAKE_CXX_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
    # set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE ccache)
    # set_property(GLOBAL PROPERTY RULE_LAUNCH_LINK ccache)
  else()
    message(STATUS "Disable ccache because of no ccache installed")
  endif()
endmacro()

ccache_enable()
