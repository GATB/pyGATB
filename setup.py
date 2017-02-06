from setuptools import setup, find_packages
from distutils.sysconfig import get_python_lib
import glob
import os
import sys

if os.path.exists('readme.rst'):
    print("""The setup.py script should be executed from the build directory.

Please see the file 'readme.rst' for further instructions.""")
    sys.exit(1)


setup(
    name = "pyGATB",
    packages=find_packages('src'),
    package_dir = {'': 'src'},
    py_modules = ['plot_graph'],
    data_files = [(get_python_lib(), glob.glob('src/*.so')),
                  #('bin', ['bin/rectangle-props'])
                 ],
    author = 'Matt McCormick',
    description = 'Use the CMake build system to make Cython modules.',
    license = 'Apache',
    keywords = 'cmake cython build',
    setup_requires=['pytest-runner'],
    tests_require=['pytest'],
    zip_safe = False,
    )
