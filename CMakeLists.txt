project(pyGATB)

cmake_minimum_required( VERSION 3.1.0 )

# TODO: set flags per target, checks compiler capabilities
set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_C_VISIBILITY_PRESET hidden)
set(CMAKE_VISIBILITY_INLINES_HIDDEN ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Compiler cache support with ccache
find_program(CCACHE_FOUND ccache)
if(CCACHE_FOUND)
    set(ENABLE_CCACHE ON CACHE BOOL "Enable ccache")
    if(${ENABLE_CCACHE})
        set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE ccache)
        set_property(GLOBAL PROPERTY RULE_LAUNCH_LINK ccache)
    endif()
endif(CCACHE_FOUND)

################################################################################
# The version number.
################################################################################
SET (gatb-tool_VERSION_MAJOR 1)
SET (gatb-tool_VERSION_MINOR 0)
SET (gatb-tool_VERSION_PATCH 0)

IF (DEFINED MAJOR)
    SET (gatb-tool_VERSION_MAJOR ${MAJOR})
ENDIF()
IF (DEFINED MINOR)
    SET (gatb-tool_VERSION_MINOR ${MINOR})
ENDIF()
IF (DEFINED PATCH)
    SET (gatb-tool_VERSION_PATCH ${PATCH})
ENDIF()

set (gatb-tool-version ${gatb-tool_VERSION_MAJOR}.${gatb-tool_VERSION_MINOR}.${gatb-tool_VERSION_PATCH})

################################################################################
# Define cmake modules directory
################################################################################
SET (GATB_CORE_HOME  ${PROJECT_SOURCE_DIR}/thirdparty/gatb-core)
SET (CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_LIST_DIR}/cmake ${GATB_CORE_HOME}/gatb-core/cmake)

include (CheckLTO)
check_lto ()

if(LTO_CFLAGS)
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} ${LTO_CFLAGS}")
    set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} ${LTO_CFLAGS}")
    set(CMAKE_LD_FLAGS_RELEASE "${CMAKE_LD_FLAGS_RELEASE} ${CMAKE_CXX_FLAGS_RELEASE} ${LTO_CFLAGS}")
endif()

################################################################################
# SUPPORTED KMER SIZES
################################################################################

# One can uncomment this line and set the wanted values
#set (KSIZE_LIST "32")

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
#add_subdirectory( bin )

################################################################################
# Packaging
################################################################################
# We set the version number
SET (CPACK_PACKAGE_DESCRIPTION_SUMMARY  "gatb-tool ${PROJECT_NAME}")
SET (CPACK_PACKAGE_VENDOR               "Genscale team (INRIA)")
SET (CPACK_PACKAGE_VERSION_MAJOR        "${gatb-tool_VERSION_MAJOR}")
SET (CPACK_PACKAGE_VERSION_MINOR        "${gatb-tool_VERSION_MINOR}")
SET (CPACK_PACKAGE_VERSION_PATCH        "${gatb-tool_VERSION_PATCH}")
SET (CPACK_PACKAGE_VERSION              "${gatb-tool-version}")  

# We set the kind of archive
SET (CPACK_GENERATOR                    "TGZ")
SET (CPACK_SOURCE_GENERATOR             "TGZ")

# Packaging the source ; we ignore unwanted files 
SET (CPACK_SOURCE_IGNORE_FILES          
    "^${PROJECT_SOURCE_DIR}/build/"  
    "^${GATB_CORE_HOME}/.project"
    "^${GATB_CORE_HOME}/.gitignore"
    "^${GATB_CORE_HOME}/doc"
    "^${GATB_CORE_HOME}/DELIVERY.md"
)

# Packaging the binary ; we want to include some additional files
INSTALL (FILES   ${CMAKE_CURRENT_SOURCE_DIR}/LICENCE                     DESTINATION .)
INSTALL (FILES   ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/THIRDPARTIES.md  DESTINATION .)

include (CPack)
