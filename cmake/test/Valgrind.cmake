#[[
Configure valgrind to check memcheck on testsuit

Note:
  This requires enable the testing.

]]
include_guard(GLOBAL)

find_program(
  VALGRIND_COMMAND
  NAMES valgrind
  DOC "valgrind executable")

set(USE_VALGRIND
    "--leak-check=full --gen-suppressions=all --track-origins=yes"
    CACHE STRING "use valgrind to check memory issues.")

if(VALGRIND_COMMAND)
  message(
    STATUS
      "Activate valgrind: ${VALGRIND_COMMAND}.
      USE_VALGRIND default options: --leak-check=full --gen-suppressions=all --track-origins=yes
      Options:
        --show-leak-kinds=all - show all possible leak
        --gen-suppressions=all - gen suppress info automatically
        --track-origins=yes - locates the original position
        --suppressions=\"${CMAKE_SOURCE_DIR}/valgrind_suppress.txt\" - use valgrind suppress config file"
  )
endif()

if(NOT CMAKE_HOST_UNIX)
  message(STATUS "Disable valgrind on non-unix system")
  return()
endif()

if(VALGRIND_COMMAND)
  set(VALGRIND_COMMAND_OPTIONS "${USE_VALGRIND}")
else()
  message(WARNING "Not found valgrind, please check valgrind existence")
endif()
