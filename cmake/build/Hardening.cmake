#[[
Hardening is a CMake module that provides a set of functions to harden CMake projects against common vulnerabilities.

References:

- <https://best.openssf.org/Compiler-Hardening-Guides/Compiler-Options-Hardening-Guide-for-C-and-C++.html>
- <https://github.com/ossf/wg-best-practices-os-developers
- <https://learn.microsoft.com/en-us/archive/msdn-magazine/2008/march/security-briefs-protecting-your-code-with-visual-c-defenses
- <https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html#minimal-runtime>

Example:

    include(Hardening)
]]

include_guard(GLOBAL)

include(${CMAKE_CURRENT_LIST_DIR}/../Common.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/Sanitizer.cmake)

set(USE_HARDENING
    ON
    CACHE BOOL "Enable hardening compilation flags")

if(MSVC)
  set(USE_HARDENING_FLAGS
      /sdl # Enable additional security checks
      /guard:cf # Control Flow Guard
      /NXCOMPAT # Data Execution Prevention
      /DYNAMICBASE # Image Randomization
      /CETCOMPAT # Enhanced Mitigation Experience Toolkit (EMET)
  )

  set(USE_HARDENING_LINKS
      /NXCOMPAT # Data Execution Prevention
      /CETCOMPAT # Enhanced Mitigation Experience Toolkit (EMET)
  )
else()
  set(USE_HARDENING_FLAGS
      -D_GLIBCXX_ASSERTIONS # Enable assertions
      -U_FORTIFY_SOURCE # Disable stack protector
      -D_FORTIFY_SOURCE=3 # Enable stack protector
      -fstack-protector-strong # Enable stack protector
      -fcf-protection # Control Flow Guard
      -fstack-clash-protection # Control Flow Guard
      -Wimplicit-fallthrough # Enabled in compiler flags by default
      -fstrict-flex-arrays=3 # Enable strict array bounds
      -Wformat # Enabled in compiler flags by default
      -Wformat=2 # Enabled in compiler flags by default
      -Wl,-z,nodlopen # Restrict dlopen(3) calls to shared objects
      -Wl,-z,noexecstack # Enable data execution prevention by marking stack
                         # memory as non-executable
      -Wl,-z,relro # Mark relocation table entries resolved at load-time as
                   # read-only
      -Wl,-z,now # Mark relocation table entries resolved at load-time as
                 # read-only. It impacts startup performance
      "-fsanitize=undefined -fsanitize-minimal-runtime" # Enable minimal runtime
                                                        # undefined behavior
                                                        # sanitizer
      -fno-delete-null-pointer-checks
      -fno-strict-overflow
      -fno-strict-aliasing
      -ftrivial-auto-var-init=zero
      -Wtrampolines # Enable trampolines(gcc only)
      -mbranch-protection=standard # Enable indirect branches(aarch64 only)
  )

  set(USE_HARDENING_LINKS
      -fstack-protector-strong # Enable stack protector
      "-fsanitize=undefined -fsanitize-minimal-runtime" # Enable minimal runtime
                                                        # undefined behavior
                                                        # sanitizer
      -Wl,-z,nodlopen # Restrict dlopen(3) calls to shared objects
      -Wl,-z,noexecstack # Enable data execution prevention by marking stack
                         # memory as non-executable
      -Wl,-z,relro # Mark relocation table entries resolved at load-time as
                   # read-only
      -Wl,-z,now # Mark relocation table entries resolved at load-time as
                 # read-only. It impacts startup performance
  )
endif()

message(
  STATUS
    "Use hardening compilation with USE_HARDENING: ${USE_HARDENING}
  Hardening Options:
    USE_HARDENING_FLAGS: Default is ${USE_HARDENING_FLAGS}
    USE_HARDENING_LINKS: Default is ${USE_HARDENING_LINKS}
    USE_HARDENING_SKIP_TARGETS_REGEXES: List of regexes to skip targts. Default is empty."
)

if(NOT USE_HARDENING)
  message(STATUS "Hardening disabled by USE_HARDENING evaluates to false")
endif()

message(VERBOSE "Check Hardening flags: ${USE_HARDENING_FLAGS}")

foreach(_harden ${USE_HARDENING_FLAGS})
  check_and_append_flag(FLAGS ${_harden} TARGETS hardening_flags)
endforeach()

flags_to_list(hardening_flags "${hardening_flags}")

message(VERBOSE "Check Hardening links: ${USE_HARDENING_LINKS}")

foreach(_harden ${USE_HARDENING_LINKS})
  flags_to_list(_harden_list "${_harden}")
  if(hardening_flags MATCHES "${_harden_list}")
    list(APPEND hardening_links ${_harden})
  endif()
endforeach()

# Enable minimal runtime undefined but not not propagete globally, see
# https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html#minimal-runtime
if(hardening_flags MATCHES "-fsanitize=undefined;-fsanitize-minimal-runtime")
  message(VERBOSE
          "Try to enabling minimal runtime undefined behavior sanitizer")
  check_and_append_flag(FLAGS "-fno-sanitize-recover=undefined" TARGETS
                        no_sanitize_recover_ub)
  flags_to_list(no_sanitize_recover_ub "${no_sanitize_recover_ub}")
  list(APPEND hardening_flags ${no_sanitize_recover_ub})
  list(APPEND hardening_links ${no_sanitize_recover_ub})
endif()

flags_to_list(hardening_links "${hardening_links}")

# Handle the conflics between hardening ubsan and asan
if(san_available_flags MATCHES "-fsanitize=address")
  message(
    WARNING "Try to disable usan minimal runtime due to conflict with asan")
  list(REMOVE_ITEM hardening_flags "-fsanitize=undefined"
       "-fsanitize-minimal-runtime" "-fno-sanitize-recover=undefined")
  list(REMOVE_ITEM hardening_links "-fsanitize=undefined"
       "-fsanitize-minimal-runtime" "-fno-sanitize-recover=undefined")
endif()

message(STATUS "Final Hardening flags: ${hardening_flags}")
message(STATUS "Final Hardening links: ${hardening_links}")

function(harden_target target)
  if(NOT USE_HARDENING)
    message(
      VERBOSE
      "Skipping hardening for target ${target} due to USE_HARDENING evaluates to false"
    )
    return()
  endif()

  if(USE_HARDENING_SKIP_TARGETS_REGEXES)
    foreach(regex ${USE_HARDENING_SKIP_TARGETS_REGEXES})
      if(target MATCHES "${regex}")
        message(
          VERBOSE
          "Skipping ${target} by ${CMAKE_CURRENT_FUNCTION} due to regex: ${regex}"
        )
        return()
      endif()
    endforeach()
  endif()

  get_target_property(_target_type ${target} TYPE)

  if(NOT MSVC AND (_target_type STREQUAL "EXECUTABLE" OR _target_type STREQUAL
                                                         "SHARED_LIBRARY"))
    if(_target_type STREQUAL "EXECUTABLE")
      check_and_append_flag(FLAGS "-fPIE -pie" TARGETS target_flags)
      flags_to_list(target_flags "${target_flags}")
    elseif(_target_type STREQUAL "SHARED_LIBRARY")
      check_and_append_flag(FLAGS "-fPIC -shared" TARGETS target_flags)
      flags_to_list(target_flags "${target_flags}")
    endif()
  endif()

  set(FLAGS ${hardening_flags} ${target_flags})
  set(LINKS ${hardening_links} ${target_flags})

  message(VERBOSE "Hardening target ${target} by ${CMAKE_CURRENT_FUNCTION}:
    Hardening compiling flags: ${FLAGS}
    Hardening linking flags: ${LINKS}")

  options_target(${target} FLAGS ${FLAGS} LINKS ${LINKS})
endfunction()
