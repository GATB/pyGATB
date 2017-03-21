# If the pyx file is a C++ file, we should specify that here.


set_source_files_properties(
  ${pyGATB_SOURCE_DIR}/src/bank.pyx
  ${pyGATB_SOURCE_DIR}/src/graph.pyx
  PROPERTIES CYTHON_IS_CXX TRUE )

# Multi-file cython modules do not appear to be working at the moment.
cython_add_module(bank bank.pyx)
set_property(TARGET bank PROPERTY CXX_STANDARD 11)
target_link_libraries(bank gatbcore-static z)

cython_add_module(graph graph.pyx)
set_property(TARGET graph PROPERTY CXX_STANDARD 11)
target_link_libraries(graph gatbcore-static z hdf5)



