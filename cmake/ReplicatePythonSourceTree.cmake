# Note: when executed in the build dir, then CMAKE_CURRENT_SOURCE_DIR is the
# build dir.

file( COPY setup.py MANIFEST.in src tests bin DESTINATION "${CMAKE_ARGV3}"
  FILES_MATCHING PATTERN "*.py" )
file( COPY setup.cfg DESTINATION "${CMAKE_ARGV3}")
