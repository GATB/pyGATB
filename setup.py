from setuptools import setup, Extension, Distribution
import os
import sys

def fatal_error(reason):
    print('ERROR:', reason, file=sys.stderr)
    sys.exit(1)

if os.path.exists('CMakeLists.txt'):
    fatal_error("The setup.py script should be executed from the build directory. Please see the file 'README.md' for instructions.")

if 'sdist' in sys.argv:
    fatal_error("This package contains precompiled extension modules, it cannot be distributed as a source package.")

__version__ = open(os.path.join(os.path.dirname(__file__), 'src/VERSION')).read().strip()
long_description = open(os.path.join(os.path.dirname(__file__), 'README.rst')).read()

# We have to trick distutils into thinking that we have an "extension module"
# even if it is not declared because we compile it our-self. This change the way
# bdists, eggs, and wheels are emitted, by tagging them with a platform dependant
# tag.

# One part of the goal is to have Distribution.has_ext_modules() returning True
# (which further implies that Distribution.is_pure() is False). This could be
# accomplished with a simple shim :

# class BinaryDistribution(Distribution):
#     """Since we don't use distutils Extension mecanism for building the module
#     we have to fake it by overloading Distribution.
#     """
#     def has_ext_modules(self):
#         return True

# Sadly this is not enough : some part of distutils bypasses has_ext_modules()
# by testing the truth value of the ext_modules directly.

# One solution would be patching Extension to skip the compilation passe, but
# Extension is only a declarative interface : the actual compilation is made out
# of the class in the build_ext command. This route could be further explored by
# looking at how Cython manage to do this (it seems that it implements its own
# build_ext)

# For now, the simplest (but quite hackish) solution I came with is an empty
# list that lies by telling that its length is 1 (implying a True truth value):

class FakeNonEmptyList(list):
    def __len__(self): return 1

setup(
    # Package description
    name = "pyGATB",
    version = __version__,
    description = 'An experimental python wrapper for gatb-core',
    long_description = long_description,
    keywords = 'gatb debruijn genomics assembly',
    license = 'AGPLv3',
    author = 'gatb-tools team',
    author_email = 'gatb-tools-support@lists.gforge.inria.fr',
    url = 'https://gatb.inria.fr/',
    classifiers=[
        # Topic
        'Topic :: Scientific/Engineering :: Bio-Informatics',
        'Topic :: Scientific/Engineering :: Medical Science Apps.',
        'Topic :: Scientific/Engineering :: Information Analysis',
        'Topic :: Scientific/Engineering :: Visualization',
        'Topic :: Software Development :: Libraries :: Application Frameworks',
        'Topic :: Software Development :: Libraries :: Python Modules',

        # Audience
        'Intended Audience :: Science/Research',
        'Intended Audience :: Developers',
        'Intended Audience :: Healthcare Industry',
        'Intended Audience :: Education',

        'License :: OSI Approved :: GNU Affero General Public License v3',

        # How mature is this project? Common values are
        #   3 - Alpha
        #   4 - Beta
        #   5 - Production/Stable
        'Development Status :: 3 - Alpha',

        # Environnement, OS, languages
        'Environment :: Console',

        'Operating System :: MacOS :: MacOS X',
        'Operating System :: POSIX :: Linux',
        'Operating System :: POSIX',

        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.3',
        'Programming Language :: Python :: 3.4',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: Implementation :: CPython',
        'Programming Language :: C++',
        'Programming Language :: Cython',
    ],

    # Package content
    packages=['gatb', 'gatb.tests'],
    package_dir = {'gatb': 'src'},
    package_data = {'gatb': ['core.so', 'VERSION'],
                    'gatb.tests': ['db/*']
                    },
    data_files = [('', ['LICENSE'])],

    #distclass=BinaryDistribution,
    #ext_modules = [Extension('test', ['test.c'])],
    ext_modules = FakeNonEmptyList(),

    # Runtime dependencies
    setup_requires = ['pytest-runner'] if {'pytest', 'test', 'ptr'}.intersection(sys.argv) else [],
    tests_require = ['pytest'],
    extras_require = {
            'igraph': 'python-igraph>=0.7'
        },
    )
