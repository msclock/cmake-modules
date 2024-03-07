#[[
Configure valgrind to check memcheck on testsuit

Note:
  This requires enable the testing.

Example:

  include(Valgrind)

]]
include_guard(GLOBAL)

set(USE_VALGRIND
    "--leak-check=full --gen-suppressions=all --track-origins=yes"
    CACHE STRING "use valgrind to check memory issues.")

message(
  STATUS
    "Activate valgrind with USE_VALGRIND: ${USE_VALGRIND}
  Options:
    --show-leak-kinds=all - show all possible leak
    --gen-suppressions=all - gen suppress info automatically
    --track-origins=yes - locates the original position
    --suppressions=\"\${CMAKE_SOURCE_DIR}/valgrind_suppress.txt\" - use valgrind suppress config file"
)

if(NOT CMAKE_HOST_UNIX OR NOT USE_VALGRIND)
  message(STATUS "Disable valgrind on non-unix system")
  return()
endif()

find_program(
  VALGRIND_COMMAND
  NAMES valgrind
  DOC "valgrind executable")

if(VALGRIND_COMMAND)
  set(VALGRIND_COMMAND_OPTIONS
      "${USE_VALGRIND}"
      CACHE STRING "valgrind options" FORCE)
else()
  message(WARNING "Not found valgrind, please check valgrind existence")
endif()
