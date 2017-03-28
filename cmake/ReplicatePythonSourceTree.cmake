# Note: when executed in the build dir, then CMAKE_CURRENT_SOURCE_DIR is the
# build dir.



file( COPY README setup.py src bin DESTINATION "${CMAKE_ARGV3}"
  FILES_MATCHING PATTERN "*.py" )

file( COPY tests DESTINATION "${CMAKE_ARGV3}/src"
  FILES_MATCHING PATTERN "*.py" )

file( COPY thirdparty/gatb-core/gatb-core/test/db DESTINATION "${CMAKE_ARGV3}/src/tests" )
file( COPY setup.cfg DESTINATION "${CMAKE_ARGV3}")
