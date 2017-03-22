project(pyGATB)

cmake_minimum_required( VERSION 3.1.0 )

# Compiler cache support with ccache
find_program(CCACHE_FOUND ccache)
if(CCACHE_FOUND)
    set(ENABLE_CCACHE ON CACHE BOOL "Enable ccache")
    if(${ENABLE_CCACHE})
        set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE ccache)
        set_property(GLOBAL PROPERTY RULE_LAUNCH_LINK ccache)
    endif()
endif(CCACHE_FOUND)

FIND_PROGRAM(PYTHON_EXECUTABLE NAMES python3.4 python3)

################################################################################
# Global compiler option
################################################################################
set(LINKER_FLAGS "${LINKER_FLAGS} -Wl,--as-needed -Wl,--allow-shlib-undefined")
set(COMPILER_FLAGS "${COMPILER_FLAGS} -fvisibility-inlines-hidden")


set(ENABLE_LTO OFF CACHE BOOL "Enable Link Time Optimizations")
if(${ENABLE_LTO} AND CMAKE_BUILD_TYPE STREQUAL "Release")
message("LTO ENABLED!!!")
    if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
        find_program (AR_FOUND NAMES gcc-ar)

        set(COMPILER_FLAGS "${COMPILER_FLAGS} -flto")
        set(LIKER_FLAGS "${LIKER_FLAGS} -fuse-linker-plugin")

    elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
        find_program (AR_FOUND NAMES llvm-ar)

        if (CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 3.9)
            set(COMPILER_FLAGS "${COMPILER_FLAGS} -flto=thin")
        else()
            set(COMPILER_FLAGS "${COMPILER_FLAGS} -flto")
        endif()
    endif()

    set(CMAKE_C_ARCHIVE_CREATE "${AR_FOUND} qcs <TARGET> <OBJECTS>")
    set(CMAKE_C_ARCHIVE_FINISH "")
    set(CMAKE_CXX_ARCHIVE_CREATE "${AR_FOUND} qcs <TARGET> <OBJECTS>")
    set(CMAKE_CXX_ARCHIVE_FINISH "")
endif()


# Apply configuration to CMake variables
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${COMPILER_FLAGS}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${COMPILER_FLAGS}")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${LIKER_FLAGS}")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${LIKER_FLAGS}")

################################################################################
# Define cmake modules directory
################################################################################
SET (GATB_CORE_HOME  ${PROJECT_SOURCE_DIR}/thirdparty/gatb-core)
SET (CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_LIST_DIR}/cmake ${GATB_CORE_HOME}/gatb-core/cmake)


################################################################################
# SUPPORTED KMER SIZES
################################################################################

# One can uncomment this line and set the wanted valuesFunction missing ending ")".  End of file
set (KSIZE_LIST "32" CACHE STRING "Supported kmer sizes")

################################################################################
# THIRD PARTIES
################################################################################

# We don't want to install some GATB-CORE artifacts
SET (GATB_CORE_EXCLUDE_TOOLS     1)
SET (GATB_CORE_EXCLUDE_TESTS     1)
SET (GATB_CORE_EXCLUDE_EXAMPLES  1)
SET (GATB_CORE_INSTALL_EXCLUDE   1)

# GATB CORE
include (GatbCore)
foreach(TARGET_NAME gatbcore-static hdf5)
    target_compile_options(${TARGET_NAME} PRIVATE -fvisibility=hidden)
endforeach()


################################################################################
# PyGATB
################################################################################

# Include the CMake script UseCython.cmake.  This defines add_cython_module().
# Instruction for use can be found at the top of cmake/UseCython.cmake.
include( UseCython )


# With CMake, a clean separation can be made between the source tree and the
# build tree.  When all source is compiled, as with pure C/C++, the source is
# no-longer needed in the build tree.  However, with pure *.py source, the
# source is processed directly.  To handle this, we reproduce the availability
# of the source files in the build tree.
add_custom_target( ReplicatePythonSourceTree ALL ${CMAKE_COMMAND} -P
  ${CMAKE_CURRENT_SOURCE_DIR}/cmake/ReplicatePythonSourceTree.cmake
  ${CMAKE_CURRENT_BINARY_DIR}
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} )

include_directories(${pyGATB_SOURCE_DIR}/include)
include_directories(${gatb-core-includes})

enable_testing()
add_test( python_tests "${PYTHON_EXECUTABLE}" setup.py test)
# Process the CMakeLists.txt in the 'src' and 'bin' directory.
add_subdirectory( src )
