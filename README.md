# CMake Modules

Include some modules in CMake.

## Usage

### Common Usage

Normally, the modules can be referred by add to the project module folders and include the needed module.

```bash
git clone --depth 1 https://github.com/msclock/cmake-modules.git cmake/cmake-modules
```

Add to CMAKE_MODULE_PATH and refer the modules.
```cmake
list(APPEND CMAKE_MODULE_PATH cmake/cmake-modules)
include(module/path/without/.cmake/suffix)
```

### Using registry

There presents a cmake registry facilitates the cmake modules to refer. An example is [here](https://github.com/msclock/cpp-scaffold).

## Configure

Include some modules for handling configuration in CMake.

- Default
- Common
- CheckBuildDir
- ConfigDebug
- ConfigDoxygen
- FindSphinx
- UniqueOutputBinaryDir

## Build

Include some modules for handling build in CMake.

- Default
- Ccache
- LinkOptimization
- Sanitizer
- Valgrind

## Install

Include some modules for handling installation in CMake.

- Default
- Common
- InstallDependency
- Runpath

## Test

Include some modules for handling test in CMake.

- Default
- Coverage
