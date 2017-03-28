from setuptools import setup, Extension, Distribution
import os
import sys

def fatal_error(reason):
    print('ERROR:', reason, file=sys.stderr)
    sys.exit(1)

if os.path.exists('CMakeLists.txt'):
    fatal_error("The setup.py script should be executed from the build directory. Please see the file 'README.md' for further instructions.")

if 'sdist' in sys.argv:
    fatal_error("This package contains precompiled extension modules, it cannot be distributed as a source package.")


class BinaryDistribution(Distribution):
    """Since we don't use distutils Extension mecanism for building the module
    we have to fake it by overloading Distribution.
    """
    def has_ext_modules(self):
        return True


setup(
    # Package description
    #eager_resources=['pyGATB/graph.so', 'src/graph.so', 'graph.so'],
    name = "pyGATB",
    version = '0.1',
    description = 'An experimental python wrapper for gatb-core',
    keywords = 'gatb debruijn genomic assembly',
    license = 'AGPL',
    author = 'gatb-tools team',
    author_email = 'gatb-tools-support@lists.gforge.inria.fr',
    url = 'https://gatb.inria.fr/',
    # Package content
    packages=['pyGATB', 'pyGATB.tests'],
    package_dir = {'pyGATB': 'src'},
    package_data = {'pyGATB': ['*.so'], 'pyGATB.tests': ['db/*']},
    #eager_resources=['*.so'],
    distclass=BinaryDistribution,
    zip_safe = False,
    # Runtime dependencies
    setup_requires = ['pytest-runner'] if {'pytest', 'test', 'ptr'}.intersection(sys.argv) else [],
    tests_require = ['pytest'],
    extras_require = {
            'igraph': 'python-igraph>=0.7'
        },
    )
