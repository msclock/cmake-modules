#[[
Package generation using CPack

References:
  - https://github.com/MangaD/cpp-project-template/blob/main/cmake/cpack_module.cmake
  - https://github.com/gabime/spdlog/blob/v1.x/cmake/spdlogCPack.cmake
  - https://github.com/retifrav/cmake-cpack-example/tree/master
]]
include_guard(GLOBAL)

set(CPACK_RESOURCE_FILE_README
    "${CMAKE_CURRENT_SOURCE_DIR}/README.md"
    CACHE STRING "Readme")
set(CPACK_RESOURCE_FILE_LICENSE
    "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE"
    CACHE STRING "License")
set(CPACK_SOURCE_GENERATOR
    "TGZ;ZIP"
    CACHE STRING "Source generator")
# cmake-format: off
set(CPACK_SOURCE_IGNORE_FILES
  /.git
  /dist
  /.*build.*
  /\\\\.DS_Store
)
# cmake-format: on

include(CPack)
