#!/bin/bash

# Usage: ./setup_cpp_project.sh <project_name> <c++_standard>
# Example: ./setup_cpp_project.sh MyProject 20

set -e

# Check for required arguments
if [ $# -ne 2 ]; then
    echo "Usage: $0 <project_name> <c++_standard>"
    exit 1
fi

PROJECT_NAME=$1
CPP_STANDARD=$2

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install GCC 14 if not already installed
if ! brew list gcc@14 &> /dev/null; then
    echo "Installing GCC 14..."
    brew install gcc@14
fi

# Install Ninja if not already installed
if ! brew list ninja &> /dev/null; then
    echo "Installing Ninja..."
    brew install ninja
fi

# Determine the number of CPU cores
TOTAL_CORES=$(sysctl -n hw.ncpu)
if [ "$TOTAL_CORES" -gt 3 ]; then
    BUILD_THREADS=$((TOTAL_CORES - 1))
else
    BUILD_THREADS=1
fi

# Create project directory
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Create main.cpp
cat <<EOF > main.cpp
#include <iostream>

int main() {
    std::cout << "Hello, $PROJECT_NAME!" << std::endl;
    return 0;
}
EOF

# Create CMakeLists.txt
cat <<EOF > CMakeLists.txt
cmake_minimum_required(VERSION 3.20)
project($PROJECT_NAME LANGUAGES CXX)

set(CMAKE_CXX_STANDARD $CPP_STANDARD)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

include(cmake/CPM.cmake)

# CPMAddPackage(
#  NAME nlohmann_json
#  GITHUB_REPOSITORY nlohmann/json
#  VERSION 3.11.2
#)

add_executable(\${PROJECT_NAME} main.cpp)
# target_link_libraries(\${PROJECT_NAME} PRIVATE nlohmann_json::nlohmann_json)
EOF

# Create cmake directory and download CPM.cmake
mkdir -p cmake
curl -fsSL https://github.com/cpm-cmake/CPM.cmake/releases/latest/download/CPM.cmake -o cmake/CPM.cmake

# Create build directory
mkdir -p build

# Generate Makefile with proper tab indentation
{
    echo ".PHONY: all build clean rebuild"
    echo
    echo "all: build"
    echo
    echo "build:"
    printf '\tcmake -S . -B build -G Ninja \\\n'
    printf '\t\t-DCMAKE_C_COMPILER=%s/bin/gcc-14 \\\n' "$(brew --prefix gcc@14)"
    printf '\t\t-DCMAKE_CXX_COMPILER=%s/bin/g++-14 \\\n' "$(brew --prefix gcc@14)"
    printf '\t\t-DCMAKE_EXPORT_COMPILE_COMMANDS=ON\n'
    printf '\tcmake --build build --parallel %d\n' "$BUILD_THREADS"
    echo
    echo "clean:"
    printf '\trm -rf build\n'
    echo
    echo "rebuild: clean build"
} > Makefile

echo "Project $PROJECT_NAME has been set up with C++$CPP_STANDARD standard."
echo "Use 'make' to build, 'make clean' to clean, and 'make rebuild' to rebuild the project."
