#[[
This module provides tools to check and configure compiler options for targets.

See https://github.com/lefticus/cppbestpractices/blob/master/02-Use_the_Tools_Available.md for more information.
]]

include_guard(GLOBAL)

include(${CMAKE_CURRENT_LIST_DIR}/../Common.cmake)

set(COMPILER_FLAGS_WARNINGS_CXX
    /W4 # Baseline reasonable warnings
    /w14242 # 'identifier': conversion from 'type1' to 'type2', possible loss of
            # data
    /w14254 # 'operator': conversion from 'type1:field_bits' to
            # 'type2:field_bits', possible loss of data
    /w14263 # 'function': member function does not override any base class
            # virtual member function
    /w14265 # 'classname': class has virtual functions, but destructor is not
            # virtual instances of this class may not be destructed correctly
    /w14287 # 'operator': unsigned/negative constant mismatch
    /we4289 # nonstandard extension used: 'variable': loop control variable
            # declared in the for-loop is used outside the for-loop scope
    /w14296 # 'operator': expression is always 'boolean_value'
    /w14311 # 'variable': pointer truncation from 'type1' to 'type2'
    /w14545 # expression before comma evaluates to a function which is missing
            # an argument list
    /w14546 # function call before comma missing argument list
    /w14547 # 'operator': operator before comma has no effect; expected operator
            # with side-effect
    /w14549 # 'operator': operator before comma has no effect; did you intend
            # 'operator'?
    /w14555 # expression has no effect; expected expression with side- effect
    /w14619 # pragma warning: there is no warning number 'number'
    /w14640 # Enable warning on thread un-safe static member initialization
    /w14826 # Conversion from 'type1' to 'type2' is sign-extended. This may
            # cause unexpected runtime behavior.
    /w14905 # wide string literal cast to 'LPSTR'
    /w14906 # string literal cast to 'LPWSTR'
    /w14928 # illegal copy-initialization; more than one user-defined conversion
            # has been implicitly applied
    /permissive- # standards conformance mode for MSVC compiler.
    -Wall # all warnings on
    -Wextra # reasonable and standard
    -Wshadow # warn the user if a variable declaration shadows one from a parent
             # context
    -Wnon-virtual-dtor # warn the user if a class with virtual functions has a
                       # non-virtual destructor. This helps catch hard to track
                       # down memory errors
    -Wold-style-cast # warn for c-style casts
    -Wcast-align # warn for potential performance problem casts
    -Wunused # warn on anything being unused
    -Woverloaded-virtual # warn if you overload (not override) a virtual
                         # function
    -Wpedantic # warn if non-standard C++ is used
    -Wconversion # warn on type conversions that may lose data
    -Wsign-conversion # warn on sign conversions
    -Wnull-dereference # warn if a null dereference is detected
    -Wdouble-promotion # warn if float is implicit promoted to double
    -Wformat=2 # warn on security issues around functions that format output (ie
               # printf)
    -Wimplicit-fallthrough # warn on statements that fallthrough without an
                           # explicit annotation
    # GCC specific
    -Wmisleading-indentation # warn if indentation implies blocks where blocks
                             # do not exist
    -Wduplicated-cond # warn if if / else chain has duplicated conditions
    -Wduplicated-branches # warn if if / else branches have duplicated code
    -Wlogical-op # warn about logical operations being used where bitwise were
                 # probably wanted
    -Wuseless-cast # warn if you perform a cast to the same type
    -Wsuggest-override # warn if an overridden member function is not marked
                       # 'override' or 'final'
)

set(COMPILER_FLAGS_WARNINGS_CUDA
    -Wall # Wall all warnings
    -Wextra # Reasonable and standard extra warnings
    -Wunused # Warn on anything being unused
    -Wconversion # Warn on type conversions that may lose data"
    -Wshadow # Warn the user if a variable declaration shadows one from a parent
             # context
)

option(COMPILER_FLAGS_WARNINGS_AS_ERRORS "Treat Warnings As Errors" OFF)

message(
  STATUS
    "Use Compiler flags:
  Compiler Flags Options:
    COMPILER_FLAGS_WARNINGS_CXX: ${COMPILER_FLAGS_WARNINGS_CXX}
    COMPILER_FLAGS_WARNINGS_CUDA: ${COMPILER_FLAGS_WARNINGS_CUDA}
    COMPILER_FLAGS_WARNINGS_AS_ERRORS: If treat warnings as errors. Default is OFF.
    COMPILER_FLAGS_SKIP_TARGETS_REGEXES: List of regexes to skip targets. Default is empty."
)

foreach(_warn ${COMPILER_FLAGS_WARNINGS_CXX})
  check_and_append_flag(FLAGS "${_warn}" TARGETS compiler_warnings_cxx)
endforeach()

if(COMPILER_FLAGS_WARNINGS_AS_ERRORS)
  foreach(_warn /WX -Werror)
    check_and_append_flag(FLAGS "${_warn}" TARGETS compiler_warnings_cxx)
  endforeach()
endif()

# use the same warning flags for C
set(compiler_warnings_c "${compiler_warnings_cxx}")

foreach(_warn ${COMPILER_FLAGS_WARNINGS_CUDA})
  check_and_append_flag(FLAGS "${_warn}" TARGETS compiler_warnings_cuda)
endforeach()

flags_to_list(compiler_warnings_c "${compiler_warnings_c}")
flags_to_list(compiler_warnings_cxx "${compiler_warnings_cxx}")
flags_to_list(compiler_warnings_cuda "${compiler_warnings_cuda}")
message(STATUS "Compiler final warnings for C: ${compiler_warnings_c}")
message(STATUS "Compiler final warnings for CXX: ${compiler_warnings_cxx}")
message(STATUS "Compiler final warnings for CUDA: ${compiler_warnings_cuda}")

add_custom_target(compiler_flags_warnings)
set_target_properties(compiler_flags_warnings
                      PROPERTIES _c "${compiler_warnings_c}")
set_target_properties(compiler_flags_warnings
                      PROPERTIES _cxx "${compiler_warnings_cxx}")
set_target_properties(compiler_flags_warnings
                      PROPERTIES _cuda "${compiler_warnings_cuda}")
unset(compiler_warnings_c)
unset(compiler_warnings_cxx)
unset(compiler_warnings_cuda)

#[[
Function to apply compiler warnings to a target.
]]
function(warn_target target)
  if(COMPILER_FLAGS_SKIP_TARGETS_REGEXES)
    foreach(regex ${COMPILER_FLAGS_SKIP_TARGETS_REGEXES})
      if(target MATCHES "${regex}")
        message(
          VERBOSE
          "Skipping ${target} by ${CMAKE_CURRENT_FUNCTION} due to regex: ${regex}"
        )
        return()
      endif()
    endforeach()
  endif()

  get_target_property(_c compiler_flags_warnings _c)
  get_target_property(_cxx compiler_flags_warnings _cxx)
  get_target_property(_cuda compiler_flags_warnings _cuda)

  message(
    VERBOSE
    "Applying compiler warnings to target ${target} by ${CMAKE_CURRENT_FUNCTION}:
    Compiler Warnings for C: ${_c}
    Compiler Warnings for CXX: ${_cxx}
    Compiler Warnings for CUDA: ${_cuda}")

  options_target(
    ${target} FLAGS $<$<COMPILE_LANGUAGE:C>:${_c}> # C warnings
    $<$<COMPILE_LANGUAGE:CXX>:${_cxx}> # C++ warnings
    $<$<COMPILE_LANGUAGE:CUDA>:${_cuda}> # Cuda warnings
  )
endfunction()
