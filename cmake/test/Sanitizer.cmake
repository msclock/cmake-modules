#[[
Copyright (C) 2018-2022 by George Cave - gcave@stablecoder.ca

Copyright (c) 2022, 2023 msclock - msclock@qq.com

Licensed under the Apache License, Version 2.0 (the "License"); you may not
use this file except in compliance with the License. You may obtain a copy of
the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
License for the specific language governing permissions and limitations under
the License.

See https://github.com/StableCoder/cmake-scripts/blob/main/sanitizers.cmake.


Sanitizer
---------------

Sanitizers are tools that perform checks during a program’s runtime and
returns issues, and as such, along with unit testing, code coverage and static
analysis, is another tool to add to the programmers toolbox. And of course,
like the previous tools, are tragically simple to add into any project using
CMake, allowing any project and developer to quickly and easily use.

A quick rundown of the tools available, and what they do:

LeakSanitizer detects memory leaks, or issues where memory is allocated and
never deallocated, causing programs to slowly consume more and more memory,
eventually leading to a crash.


AddressSanitizer
^^^^^^^^^^^^^^^^

AddressSanitizer is a fast memory error detector. It is useful for detecting
most issues dealing with memory, such as:
    - Out of bounds accesses to heap, stack, global
    - Use after free
    - Use after return
    - Use after scope
    - Double-free, invalid free
    - Memory leaks (using LeakSanitizer)

ThreadSanitizer
^^^^^^^^^^^^^^^

ThreadSanitizer detects data races for multi-threaded code.

UndefinedBehaviourSanitizer
^^^^^^^^^^^^^^^^^^^^^^^^^^^

UndefinedBehaviourSanitizer detects the use of various features of C/C++ that
are explicitly listed as resulting in undefined behaviour. Most notably:
    - Using misaligned or null pointer.
    - Signed integer overflow
    - Conversion to, from, or between floating-point types which would overflow the destination
    - Division by zero
    - Unreachable code

MemorySanitizer
^^^^^^^^^^^^^^^

MemorySanitizer detects uninitialized reads.

CFI
^^^

Control Flow Integrity is designed to detect certain forms of undefined
behaviour that can potentially allow attackers to subvert the program's
control flow. These are used by declaring the USE_SANITIZER CMake variable as
string containing any of:
  - Address
  - Memory
  - MemoryWithOrigins
  - Undefined
  - Thread
  - Leak
  - CFI

Multiple values are allowed, e.g. -DUSE_SANITIZER=Address,Leak but some
sanitizers cannot be combined together, e.g.-DUSE_SANITIZER=Address,Memory
will result in configuration error. The delimiter character is not required
and -DUSE_SANITIZER=AddressLeak would work as well.
]]

include_guard(GLOBAL)
include(CheckCXXSourceCompiles)
include(${CMAKE_CURRENT_LIST_DIR}/../Common.cmake)

set(USE_SANITIZER
    "Address"
    CACHE STRING "Compile with sanitizer flags.")

message(
  STATUS
    "Activate sanitizer with USE_SANITIZER: ${USE_SANITIZER}
  Address,Memory can not used in combination
  Options:
    Address - detects most issues dealing with memory.
    Memory - detects uninitialized reads.
    MemoryWithOrigins - detects uninitialized reads with origins track.
    Undefined - detects the use of various undefined behaviour
    Thread - detects data races for multi-threaded code.
    Leak - detects memory leaks.
    CFI - detects potential undefined behaviours to subvert the program's control flow."
)

string(TOLOWER "${USE_SANITIZER}" USE_SANITIZER)

function(check_flags_available return_var flags)
  set(QUIET_BACKUP ${CMAKE_REQUIRED_QUIET})
  set(CMAKE_REQUIRED_QUIET TRUE)
  set(FLAGS_BACKUP ${CMAKE_REQUIRED_FLAGS})
  set(CMAKE_REQUIRED_FLAGS "${flags}")
  check_cxx_source_compiles("int main() { return 0; }" ret)
  set(${return_var}
      ${ret}
      PARENT_SCOPE)
  set(CMAKE_REQUIRED_FLAGS "${FLAGS_BACKUP}")
  set(CMAKE_REQUIRED_QUIET "${QUIET_BACKUP}")
endfunction()

#[[
A function to copy sanitizer runtime when open ASAN flags on windows.Basically,
it copy clang_rt.asan*.dll to target location.

Arguments:
  target - a target added by add_library, add_executable instructions.
]]
function(copy_sanitizer_runtime target)
  if(NOT WIN32 OR NOT USE_SANITIZER)
    return()
  endif()

  if(CMAKE_SIZEOF_VOID_P EQUAL 8) # 64-bit build
    set(ASAN_ARCHITECTURE "x86_64")
    set(ASAN_LIBRARY_HINT_DIR $ENV{VCToolsInstallDir}/bin/Hostx64/x64)
  else()
    set(ASAN_ARCHITECTURE "i386")
    set(ASAN_LIBRARY_HINT_DIR $ENV{VCToolsInstallDir}/bin/Hostx86/x86)
  endif()

  if(CMAKE_BUILD_TYPE STREQUAL Debug)
    set(ASAN_LIBRARY_NAME "clang_rt.asan_dbg_dynamic-${ASAN_ARCHITECTURE}.dll")
  else()
    set(ASAN_LIBRARY_NAME "clang_rt.asan_dynamic-${ASAN_ARCHITECTURE}.dll")
  endif()
  set(LLVM_SYMBOLIZER_NAME "llvm-symbolizer.exe")

  set(CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS ${ASAN_LIBRARY_NAME})
  find_file(
    ASAN_LIBRARY_SOURCE
    NAMES ${ASAN_LIBRARY_NAME} REQUIRED
    HINTS ${ASAN_LIBRARY_HINT_DIR} $ENV{LIBPATH}
    DOC "Clang AddressSanitizer runtime")

  find_file(
    LLVM_SYMBOLIZER_SOURCE
    NAMES ${LLVM_SYMBOLIZER_NAME} REQUIRED
    HINTS ${ASAN_LIBRARY_HINT_DIR} $ENV{LIBPATH}
    DOC "LLVM symbolizer executable")

  add_custom_command(
    COMMENT "Copying ${ASAN_LIBRARY_SOURCE} to $<TARGET_FILE_DIR:${target}>"
    MAIN_DEPENDENCY ${ASAN_LIBRARY_SOURCE}
    TARGET ${target} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${ASAN_LIBRARY_SOURCE}
            $<TARGET_FILE_DIR:${target}>)

  add_custom_command(
    COMMENT "Copying ${LLVM_SYMBOLIZER_SOURCE} to $<TARGET_FILE_DIR:${target}>"
    MAIN_DEPENDENCY ${LLVM_SYMBOLIZER_SOURCE}
    TARGET ${target} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${LLVM_SYMBOLIZER_SOURCE}
            $<TARGET_FILE_DIR:${target}>)

endfunction()

if(USE_SANITIZER)
  unset(SANITIZER_SELECTED_FLAGS)
  if(NOT MSVC AND CMAKE_HOST_UNIX)
    append_variable("-fno-omit-frame-pointer" CMAKE_C_FLAGS CMAKE_CXX_FLAGS)
    if(CMAKE_BUILD_TYPE MATCHES [[DEBUG]])
      append_variable("-O1" CMAKE_C_FLAGS CMAKE_CXX_FLAGS)
    endif()

    if(USE_SANITIZER MATCHES [[address]])
      # Optional: -fno-optimize-sibling-calls -fsanitize-address-use-after-scope
      message(DEBUG "Testing with Address sanitizer")
      set(SANITIZER_ADDR_FLAG "-fsanitize=address")
      check_flags_available(SANITIZER_ADDR_AVAILABLE ${SANITIZER_ADDR_FLAG})
      if(SANITIZER_ADDR_AVAILABLE)
        message(DEBUG "  Append flags: ${SANITIZER_ADDR_FLAG}")
        append_variable("${SANITIZER_ADDR_FLAG}" SANITIZER_SELECTED_FLAGS)
      else()
        message(
          FATAL_ERROR
            "Address sanitizer not available for ${CMAKE_CXX_COMPILER}")
      endif()
    endif()

    if(USE_SANITIZER MATCHES [[memory(withorigins)?]])
      # Optional: -fno-optimize-sibling-calls -fsanitize-memory-track-origins=2
      set(SANITIZER_MEM_FLAG "-fsanitize=memory")
      if(USE_SANITIZER MATCHES [[memorywithorigins]])
        message(DEBUG "Testing with MemoryWithOrigins sanitizer")
        append_variable("-fsanitize-memory-track-origins" SANITIZER_MEM_FLAG)
      else()
        message(DEBUG "Testing with Memory sanitizer")
      endif()
      check_flags_available(SANITIZER_MEM_AVAILABLE ${SANITIZER_MEM_FLAG})
      if(SANITIZER_MEM_AVAILABLE)
        if(USE_SANITIZER MATCHES [[memorywithorigins]])
          message(DEBUG "  Append flags: ${SANITIZER_MEM_FLAG}")
        else()
          message(DEBUG "  Append flags: ${SANITIZER_MEM_FLAG}")
        endif()
        append_variable("${SANITIZER_MEM_FLAG}" SANITIZER_SELECTED_FLAGS)

      else()
        message(
          FATAL_ERROR
            "Memory [With Origins] sanitizer not available for ${CMAKE_CXX_COMPILER}"
        )
      endif()
    endif()

    if(USE_SANITIZER MATCHES [[undefined]])
      message(DEBUG "Testing with Undefined Behaviour sanitizer")
      set(SANITIZER_UB_FLAG "-fsanitize=undefined")
      if(EXISTS "${BLACKLIST_FILE}")
        append_variable("-fsanitize-blacklist=${BLACKLIST_FILE}"
                        SANITIZER_UB_FLAG)
      endif()
      check_flags_available(SANITIZER_UB_AVAILABLE ${SANITIZER_UB_FLAG})
      if(SANITIZER_UB_AVAILABLE)
        message(DEBUG "  Append flags: ${SANITIZER_UB_FLAG}")
        append_variable("${SANITIZER_UB_FLAG}" SANITIZER_SELECTED_FLAGS)
      else()
        message(
          FATAL_ERROR
            "Undefined Behaviour sanitizer not available for ${CMAKE_CXX_COMPILER}"
        )
      endif()
    endif()

    if(USE_SANITIZER MATCHES [[thread]])
      message(DEBUG "Testing with Thread sanitizer")
      set(SANITIZER_THREAD_FLAG "-fsanitize=thread")
      check_flags_available(SANITIZER_THREAD_AVAILABLE ${SANITIZER_THREAD_FLAG})
      if(SANITIZER_THREAD_AVAILABLE)
        message(DEBUG "  Append flags: ${SANITIZER_THREAD_FLAG}")
        append_variable("${SANITIZER_THREAD_FLAG}" SANITIZER_SELECTED_FLAGS)
      else()
        message(
          FATAL_ERROR "Thread sanitizer not available for ${CMAKE_CXX_COMPILER}"
        )
      endif()
    endif()

    if(USE_SANITIZER MATCHES [[leak]])
      message(DEBUG "Testing with Leak sanitizer")
      set(SANITIZER_LEAK_FLAG "-fsanitize=leak")
      check_flags_available(SANITIZER_LEAK_AVAILABLE ${SANITIZER_LEAK_FLAG})
      if(SANITIZER_LEAK_AVAILABLE)
        message(DEBUG "  Append flags: ${SANITIZER_LEAK_FLAG}")
        append_variable("${SANITIZER_LEAK_FLAG}" SANITIZER_SELECTED_FLAGS)
      else()
        message(
          FATAL_ERROR "Thread sanitizer not available for ${CMAKE_CXX_COMPILER}"
        )
      endif()
    endif()

    if(USE_SANITIZER MATCHES [[cfi]])
      message(DEBUG "Testing with Control Flow Integrity(CFI) sanitizer")
      set(SANITIZER_CFI_FLAG "-fsanitize=cfi")
      check_flags_available(SANITIZER_CFI_AVAILABLE ${SANITIZER_CFI_FLAG})
      if(SANITIZER_CFI_AVAILABLE)
        message(DEBUG "  Append: ${SANITIZER_CFI_FLAG}")
        append_variable("${SANITIZER_LEAK_FLAG}" SANITIZER_SELECTED_FLAGS)
      else()
        message(
          FATAL_ERROR
            "Control Flow Integrity(CFI) sanitizer not available for ${CMAKE_CXX_COMPILER}"
        )
      endif()
    endif()

    message(STATUS "Build with sanitizer flags: ${SANITIZER_SELECTED_FLAGS}")
    check_flags_available(SANITIZER_SELECTED_COMPATIBLE
                          ${SANITIZER_SELECTED_FLAGS})
    if(SANITIZER_SELECTED_COMPATIBLE)
      message(STATUS " Append ${SANITIZER_SELECTED_FLAGS}")
      append_variable("${SANITIZER_SELECTED_FLAGS}" CMAKE_C_FLAGS
                      CMAKE_CXX_FLAGS)
    else()
      message(
        FATAL_ERROR
          " Sanitizer flags ${SANITIZER_SELECTED_FLAGS} are not compatible.")
    endif()
  elseif(MSVC)
    if(USE_SANITIZER MATCHES [[address]])
      set(MSVC_SANTIZER_FLAGS "/fsanitize=address")
      message(STATUS "Build with sanitizer flags: ${MSVC_SANTIZER_FLAGS}")
      # https://learn.microsoft.com/en-us/answers/questions/864574/enabling-address-sanitizer-results-in-error-lnk203
      # https://learn.microsoft.com/en-us/cpp/sanitizers/error-container-overflow?view=msvc-170
      # add_compile_definitions(_DISABLE_VECTOR_ANNOTATION)
      append_variable("${MSVC_SANTIZER_FLAGS}" CMAKE_C_FLAGS CMAKE_CXX_FLAGS)
    else()
      # llvm tool chain has same definition which is conflicit on windows with
      # symbol _calloc_dbg.
      message(
        FATAL_ERROR
          "This sanitizer not yet supported in the MSVC environment: ${USE_SANITIZER}"
      )
    endif()
  else()
    message(FATAL_ERROR "USE_SANITIZER is not supported on this platform.")
  endif()

endif()
