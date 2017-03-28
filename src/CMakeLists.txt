
set_source_files_properties( ${pyGATB_SOURCE_DIR}/src/core.pyx PROPERTIES CYTHON_IS_CXX TRUE )

cython_add_module(core core.pyx)
set_property(TARGET core PROPERTY CXX_STANDARD 11)

# Applies LINKER_FLAGS to the shared module
set_target_properties(core PROPERTIES LINK_FLAGS ${LINKER_FLAGS})
target_link_libraries(core gatbcore-static z hdf5)
