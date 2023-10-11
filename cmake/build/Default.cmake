#[[
Default to build.
]]

# Create the compile command database for clang by default
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Always build with -fPIC
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# This will cause all libraries to be built shared unless the library was
# explicitly added as a static library.  This variable is often added to
# projects as an ``option()`` so that each user of a project can decide if they
# want to build the project using shared or static libraries.
set(BUILD_SHARED_LIBS OFF)
