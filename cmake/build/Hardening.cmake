#[[
Hardening is a CMake module that provides a set of functions to harden CMake projects against common vulnerabilities.

References:

- <https://best.openssf.org/Compiler-Hardening-Guides/Compiler-Options-Hardening-Guide-for-C-and-C++.html>
- <https://github.com/ossf/wg-best-practices-os-developers
- <https://learn.microsoft.com/en-us/archive/msdn-magazine/2008/march/security-briefs-protecting-your-code-with-visual-c-defenses

Example:

    include(Hardening)
]]

include_guard(GLOBAL)

include(${CMAKE_CURRENT_LIST_DIR}/../Common.cmake)

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
      -fsanitize=undefined # Undefined behavior sanitizer
      -fno-sanitize-recover=undefined # Undefined behavior sanitizer recover
      -fno-delete-null-pointer-checks
      -fno-strict-overflow
      -fno-strict-aliasing
      -ftrivial-auto-var-init=zero
      -Wtrampolines # Enable trampolines(gcc only)
      -mbranch-protection=standard # Enable indirect branches(aarch64 only)
  )

  set(USE_HARDENING_LINKS
      -fstack-protector-strong # Enable stack protector
      -fsanitize=undefined # Undefined behavior sanitizer
      -fno-sanitize-recover=undefined # Undefined behavior sanitizer recover
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
    USE_HARDENING_MSVS_LINKS: Default is ${USE_HARDENING_LINKS}
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
  if(${_harden} IN_LIST hardening_flags)
    list(APPEND hardening_links ${_harden})
  endif()
endforeach()

flags_to_list(hardening_links "${hardening_links}")
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

  if(MSVC OR (NOT _target_type STREQUAL "EXECUTABLE"
              AND NOT _target_type STREQUAL "SHARED_LIBRARY"))
    set(FLAGS ${hardening_flags})
    set(LINKS ${hardening_links})
  else()
    if(_target_type STREQUAL "EXECUTABLE")
      check_and_append_flag(FLAGS "-fPIE -pie" TARGETS exe_flags)
      flags_to_list(exe_flags "${exe_flags}")
      set(FLAGS ${hardening_flags} ${exe_flags})
      set(LINKS ${hardening_links} ${exe_flags})
    elseif(_target_type STREQUAL "SHARED_LIBRARY")
      check_and_append_flag(FLAGS "-fPIC -shared" TARGETS shared_flags)
      flags_to_list(shared_flags "${shared_flags}")
      set(FLAGS ${hardening_flags} ${shared_flags})
      set(LINKS ${hardening_links} ${shared_flags})
    endif()
  endif()

  message(VERBOSE "Hardening target ${target} by ${CMAKE_CURRENT_FUNCTION}:
    Hardening compiling flags: ${FLAGS}
    Hardening linking flags: ${LINKS}")

  options_target(${target} FLAGS ${FLAGS} LINKS ${LINKS})
endfunction()
