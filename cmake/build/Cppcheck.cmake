#[[
Configure cppcheck for static analysisc when compiling a C++ project.

]]

include_guard(GLOBAL)

set(USE_CPPCHECK
    ON
    CACHE BOOL "Use cppcheck for static analysis of C++ code")

set(USE_CPPCHECK_OPTIONS
    --enable=style,performance,warning,portability
    --inline-suppr
    # We cannot act on a bug/missing feature of cppcheck
    --suppress=cppcheckError
    --suppress=internalAstError
    # if a file does not have an internalAstError, we get an
    # unmatchedSuppression error
    --suppress=unmatchedSuppression
    # noisy and incorrect sometimes
    --suppress=passedByValue
    # ignores code that cppcheck thinks is invalid C++
    --suppress=syntaxError
    --suppress=preprocessorErrorDirective
    --inconclusive
    CACHE STRING "cppcheck run options")

set(USE_CPPCHECK_SUPPRESS_DIR
    "*:${CMAKE_CURRENT_BINARY_DIR}/_deps/*"
    CACHE STRING "Directory to suppress cppcheck warnings")

set(USE_CPPCHECK_WARNINGS_AS_ERRORS
    OFF
    CACHE BOOL "Treat cppcheck warnings as errors")

message(
  STATUS
    "Use Cppcheck with USE_CPPCHECK: ${USE_CPPCHECK}
  Cppcheck Options:
    USE_CPPCHECK: If use cppcheck. Default is ON.
    USE_CPPCHECK_OPTIONS: cppcheck run options. Default is ${USE_CPPCHECK_OPTIONS}
    USE_CPPCHECK_SUPPRESS_DIR: Directory to suppress cppcheck warnings. Default is ${USE_CPPCHECK_SUPPRESS_DIR}
    USE_CPPCHECK_WARNINGS_AS_ERRORS: If treat warnings as errors. Default is OFF."
)

if(NOT USE_CPPCHECK)
  message(STATUS "Disable cppcheck by USE_CPPCHECK evaluates to false.")
  return()
endif()

find_program(
  CPPCHECK_COMMAND
  NAMES cppcheck
  DOC "Path to cppcheck executable")

if(NOT CPPCHECK_COMMAND)
  message(WARNING "No cppcheck found, disable cppcheck static analysis.")
  return()
endif()

# Set cppcheck template based on the generator used
if(CMAKE_GENERATOR MATCHES ".*Visual Studio.*")
  set(CPPCHECK_TEMPLATE "vs")
else()
  set(CPPCHECK_TEMPLATE "gcc")
endif()

if(VCPKG_INSTALLED_DIR AND VCPKG_TARGET_TRIPLET)
  list(APPEND USE_CPPCHECK_OPTIONS
       -I${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include
       --suppress=*:${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/*)
endif()

set(CMAKE_CXX_CPPCHECK
    ${CPPCHECK_COMMAND} --template=${CPPCHECK_TEMPLATE} ${USE_CPPCHECK_OPTIONS}
    --suppress=${USE_CPPCHECK_SUPPRESS_DIR})

if(NOT "${CMAKE_CXX_STANDARD}" STREQUAL "")
  list(APPEND CMAKE_CXX_CPPCHECK --std=c++${CMAKE_CXX_STANDARD})
endif()

if(USE_CPPCHECK_WARNINGS_AS_ERRORS)
  list(APPEND CMAKE_CXX_CPPCHECK --error-exitcode=2)
endif()
list(REMOVE_DUPLICATES CMAKE_CXX_CPPCHECK)
message(STATUS "Cppcheck final command: ${CMAKE_CXX_CPPCHECK}")
