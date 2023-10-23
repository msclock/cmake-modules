#[[
This scripts setup a runpath properly when use add_library to generate
shared libraries or executables. The path will be pointed to lib or
executable directory by variable CMAKE_INSTALL_BIN.
]]

include_guard(GLOBAL)

# use, i.e. don't skip the full RPATH for the build tree
set(CMAKE_SKIP_BUILD_RPATH FALSE)

# add the automatically determined parts of the RPATH which point to directories
# outside the build tree to the install RPATH
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

# Prepare RPATH
file(RELATIVE_PATH _rel ${CMAKE_INSTALL_FULL_BINDIR}
     ${CMAKE_INSTALL_FULL_LIBDIR})
message(
  DEBUG
  "${CMAKE_INSTALL_FULL_BINDIR} ralative to ${CMAKE_INSTALL_FULL_LIBDIR} path:${_rel}"
)
if(APPLE)
  set(_rpath "@loader_path/${_rel}")
else()
  set(_rpath "$ORIGIN/${_rel}")
endif()

# Append runtime path
list(APPEND CMAKE_INSTALL_RPATH ${_rpath};$ORIGIN)
message(STATUS "CMAKE_INSTALL_RPATH:${CMAKE_INSTALL_RPATH}")
unset(_rpath)
unset(_rel)

# Add a variable about platform shared library location
set(RUNPATH_SHARED_LOCATION
    $<IF:$<PLATFORM_ID:Windows>,${CMAKE_INSTALL_BINDIR},${CMAKE_INSTALL_LIBDIR}>
)

# Add a variable about vcpkg dependency path
set(RUNPATH_VCPKG_DPENDENCY_PATH
    ${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}$<IF:$<CONFIG:Debug>,/deubg/${RUNPATH_SHARED_LOCATION},/${RUNPATH_SHARED_LOCATION}>
)
