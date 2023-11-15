## [1.2.5](https://github.com/msclock/cmake-modules/compare/v1.2.4...v1.2.5) (2023-11-15)


### Bug Fixes

* install_target install runtime to lib location ([d1ffc42](https://github.com/msclock/cmake-modules/commit/d1ffc420bfc7a00af50e46168a40c91cb13484e5)), closes [#8](https://github.com/msclock/cmake-modules/issues/8)

## [1.2.4](https://github.com/msclock/cmake-modules/compare/v1.2.3...v1.2.4) (2023-11-10)


### Performance

* add system paths ([150d384](https://github.com/msclock/cmake-modules/commit/150d384f7c6f5c5627bb5638c3dd2b58fda1824a)), closes [#6](https://github.com/msclock/cmake-modules/issues/6)

## [1.2.3](https://github.com/msclock/cmake-modules/compare/v1.2.2...v1.2.3) (2023-10-27)


### Performance

* improve Coverage ([10654d3](https://github.com/msclock/cmake-modules/commit/10654d38326f87354a7c1b34f89571bd4d29eb56))


### CI

* use setup-python@v4 ([1cbe4f1](https://github.com/msclock/cmake-modules/commit/1cbe4f11a168005960f2a66dbebb43353722e29f))


### Docs

* fix typo in changelog ([ddc028b](https://github.com/msclock/cmake-modules/commit/ddc028b0ea7040409a3e0c139ce360891506365c))

## [1.2.2](https://github.com/msclock/cmake-modules/compare/v1.2.1...v1.2.2) (2023-10-26)


### Performance

* prefer cache dir built with CMAKE_CURRENT_FUNCTION ([92dd3d3](https://github.com/msclock/cmake-modules/commit/92dd3d34f6c34d23f6195be78f68379cb64cd78a))

## [1.2.1](https://github.com/msclock/cmake-modules/compare/v1.2.0...v1.2.1) (2023-10-25)


### Performance

* add a license install option to install_target ([293e8cc](https://github.com/msclock/cmake-modules/commit/293e8ccdb7add4269bb4a2ac31c8efed0179b48e))

## [1.2.0](https://github.com/msclock/cmake-modules/compare/v1.1.6...v1.2.0) (2023-10-25)


### Features

* add git tools module ([dfe2eab](https://github.com/msclock/cmake-modules/commit/dfe2eabc645c0721ed94b7c24d90da51d7eb58a1))

## [1.1.6](https://github.com/msclock/cmake-modules/compare/v1.1.5...v1.1.6) (2023-10-24)


### Performance

* improve install stability ([d6e9f08](https://github.com/msclock/cmake-modules/commit/d6e9f088e9332f81a4d7f655f1d86700cb25fbb4))
* unset prefix _ variables ([19776a3](https://github.com/msclock/cmake-modules/commit/19776a31087e87c6e468a9c684a5781798b95b80))

## [1.1.5](https://github.com/msclock/cmake-modules/compare/v1.1.4...v1.1.5) (2023-10-22)


### Performance

* add usage on sanitizer and hide some print info ([d94a30e](https://github.com/msclock/cmake-modules/commit/d94a30e51a584e6e1e1abb237ebaddcecc1cbaee))
* change ccache verify flow ([772f0fa](https://github.com/msclock/cmake-modules/commit/772f0fa899a43d252bd49c1dacb7d6eee8138e26))
* change valgrind flow and usage ([b444017](https://github.com/msclock/cmake-modules/commit/b44401719c934d0d44f0c30dc58697ff1ca4eb95))
* install include among modules ([4e53c96](https://github.com/msclock/cmake-modules/commit/4e53c96509c6853cb6e39bd1b8de90024a52643d))
* use PARSE_ARGV with cmake_parse_arguments ([e67a95c](https://github.com/msclock/cmake-modules/commit/e67a95c3ef0668272d46f2440b19ad7f68b86251))

## [1.1.4](https://github.com/msclock/cmake-modules/compare/v1.1.3...v1.1.4) (2023-10-22)


### Performance

* improve valgrind usability ([6583e28](https://github.com/msclock/cmake-modules/commit/6583e286580ae7667b41680ab2f5f91fd659087d))

## [1.1.3](https://github.com/msclock/cmake-modules/compare/v1.1.2...v1.1.3) (2023-10-21)


### Performance

* add a uninstall target function ([d84fd64](https://github.com/msclock/cmake-modules/commit/d84fd64235b44ced98ef5e1748dff060838cb6c9))
* add include options for install_target ([85cd50f](https://github.com/msclock/cmake-modules/commit/85cd50f1dc0d334a624f1660193ee03ac75dea4d))
* common tools ([2adcc3f](https://github.com/msclock/cmake-modules/commit/2adcc3faaf274a7d66f502cc5d38aae0b4fd79b4))

## [1.1.2](https://github.com/msclock/cmake-modules/compare/v1.1.1...v1.1.2) (2023-10-19)


### Performance

* improve annotations on runpath and install_dependency ([835cbaf](https://github.com/msclock/cmake-modules/commit/835cbafd15a81b0f61af86ed8296fa36992d6a91))

## [1.1.1](https://github.com/msclock/cmake-modules/compare/v1.1.0...v1.1.1) (2023-10-19)


### Bug Fixes

* no string output with USE_SANITIZER ([6c9435b](https://github.com/msclock/cmake-modules/commit/6c9435bc76c9df0d05d489b5535e617ead130279))


### CI

* only run on master push ([d08c280](https://github.com/msclock/cmake-modules/commit/d08c28002369d84fbc656e1ba33a565e35b2fc46))

## [1.1.0](https://github.com/msclock/cmake-modules/compare/v1.0.4...v1.1.0) (2023-10-18)


### Features

* add tools for include directories and install rules ([7cf6ed9](https://github.com/msclock/cmake-modules/commit/7cf6ed99663378878f8ec6a829100b648fadee88))

## [1.0.4](https://github.com/msclock/cmake-modules/compare/v1.0.3...v1.0.4) (2023-10-17)


### Performance

* move sanitizer and valgrind to test ([6d04824](https://github.com/msclock/cmake-modules/commit/6d04824fe522598ec7c5d6d50fe29c0140094466))


### Docs

* improve readability ([4c7e63d](https://github.com/msclock/cmake-modules/commit/4c7e63dd62d154d762f040bbb73a6b9ae04d0c71))

## [1.0.3](https://github.com/msclock/cmake-modules/compare/v1.0.2...v1.0.3) (2023-10-13)


### Performance

* remove gtest option INSTALL_GTEST ([235d880](https://github.com/msclock/cmake-modules/commit/235d8800cf69744796bb87ac91aac547d2c7e290))


### Chores

* fix typo on CHANGELOG.md ([9b53518](https://github.com/msclock/cmake-modules/commit/9b53518c104f87161c876d575d564ffcb5d3c9ca))

## [1.0.2](https://github.com/msclock/cmake-modules/compare/v1.0.1...v1.0.2) (2023-10-12)


### Performance

* add common modules and runpath paths ([b80cd66](https://github.com/msclock/cmake-modules/commit/b80cd664c7120d370870c329caa5b9f0bdc983fa))


### Docs

* improve readability ([257a12b](https://github.com/msclock/cmake-modules/commit/257a12bfde5e4a75b0497406a0778ac12c5af774))

## [1.0.1](https://github.com/msclock/cmake-modules/compare/v1.0.0...v1.0.1) (2023-10-12)


### Style

* improve comments for readability ([501604a](https://github.com/msclock/cmake-modules/commit/501604a094eeac4ae9bd7ddf95ee0057eea326fb))


### Chores

* use annotated tags ([67b18ae](https://github.com/msclock/cmake-modules/commit/67b18aea7ec22c5fd921bd2813745b4768bc1f5a))


### CI

* add release needs jobs ([8ebebcb](https://github.com/msclock/cmake-modules/commit/8ebebcb0d320ee352413d77e108bb07958600ea9))

## 1.0.0 (2023-10-11)


### Features

* add init cmake modules ([2f7131b](https://github.com/msclock/cmake-modules/commit/2f7131b16e170524d94f8476786b2528f1539c05))


### Chores

* release and pre-commit ([1a7cc34](https://github.com/msclock/cmake-modules/commit/1a7cc34c6dc530df3535982b1723c232500e85fa))
