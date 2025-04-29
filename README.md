## README

### Description
Automates creation of a new C++ project configured for a specified C++ standard on macOS.

### Usage
```bash
./setup_cpp_project.sh <project_name> <c++_standard>
# Example: ./setup_cpp_project.sh MyProject 20
```

### Behavior
1. Verifies Homebrew; installs if missing  
2. Installs GCC 14 and Ninja via Homebrew  
3. Detects CPU core count; sets build threads to (cores – 1) or 1  
4. Creates project directory and `main.cpp`  
5. Generates `CMakeLists.txt` with specified C++ standard  
6. Downloads `CPM.cmake` into `cmake/`  
7. Creates `build/` directory  
8. Generates a `Makefile` for building and cleaning

### Result
Project folder containing source, CMake config, CPM integration, build directory and Makefile.  

### License
Apache 2.0
