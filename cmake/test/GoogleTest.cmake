#[[
Enable tests based on gtest in CMake, and use CTest module to create a ``BUILD_TESTING``
option to select whether to enable tests.

Note:
  It uses the network to fetch Google Test sources make it possible to disable unit
  tests completely.

  Use the module has some requirements:
    - Being placed in front of test configuration instructions in cmake.
    - Being placed in the source directory root because ctest expects to
      find a test file in the build directory root.
]]

include_guard(GLOBAL)

# Prevent the module from being used in the wrong location
if(NOT CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
  message(
    FATAL_ERROR
      "This module should be in the project root directory and placed "
      "in front of any test configuration instructions in cmake")
endif()

# Include CTest module to enable testing support. It creates a ``BUILD_TESTING``
# option that selects whether to enable testing support (``ON`` by default).
include(CTest)
message(STATUS "Enable testing: ${BUILD_TESTING}")

if(BUILD_TESTING)
  # fetch googletest since cmake > 3.11
  include(FetchContent)

  # Declare the source and version of googletest to fetch
  FetchContent_Declare(
    googletest
    GIT_REPOSITORY https://gitlab.com/immersaview/public/remotes/googletest.git
    GIT_TAG v1.14.0)

  # For Windows: Prevent overriding the parent project's compiler/linker
  # settings

  set(gtest_force_shared_crt
      ON
      CACHE BOOL "" FORCE)

  set(INSTALL_GTEST OFF)

  # Fetch and make googletest available
  FetchContent_MakeAvailable(googletest)

  # Include GoogleTest module to add functions for using Google Test
  # infrastructure
  include(GoogleTest)
endif()
