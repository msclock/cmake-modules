#[[
Default to installation.
]]

# Include this module to search for compiler-provided system runtime libraries
# and add install rules for them.
include(InstallRequiredSystemLibraries)

# Enable installation of googletest. (Projects embedding googletest may want to
# turn this OFF.)
set(INSTALL_GTEST OFF)
