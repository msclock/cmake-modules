set(CPACK_RESOURCE_FILE_README "${CMAKE_CURRENT_SOURCE_DIR}/README.md")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")
set(CPACK_SOURCE_GENERATOR "TGZ;ZIP")
set(CPACK_SOURCE_IGNORE_FILES /.git /dist /.*build.* /\\\\.DS_Store)
include(CPack)
# https://github.com/MangaD/cpp-project-template/blob/main/cmake/cpack_module.cmake
# https://github.com/gabime/spdlog/blob/v1.x/cmake/spdlogCPack.cmake
# https://github.com/retifrav/cmake-cpack-example/tree/master
