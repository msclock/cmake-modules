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
include(cmake-modules/cmake/ProjectDefault) # Entry module for general projects
include(module/path/without/.cmake/suffix) # Include other modules
```

### Use registry

The repo has been registered in the [cmake-registry](https://github.com/msclock/cmake-registry). Here is the [usage](https://github.com/msclock/cpp-scaffold).
