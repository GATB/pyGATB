|License: Affero-GPL| |_| |Platform: C++11 Python3| |_| |Run on Linux-Mac OSX|

+--------------------+-----------------------+
| MacOSX             | Linux                 |
+====================+=======================+
| |Build Status OSX| | |Build Status Ubuntu| |
+--------------------+-----------------------+

About pyGATB
============

pyGATB is a Python3 wrapper for the `GATB-Core
library <https://github.com/GATB>`__.

The current release of pyGATB gives access to the following GATB-Core
components:

-  Bank: the class that enables to load Fasta and Fastaq files
-  Sequence: the class that holds a sequence (ID, letters, quality)
-  Graph: the class that holds the De Bruijn graph
-  Node: the class that makes graph's nodes

Using that API you can start prototyping algorithms:

- read a sequence file (Bank): FastA, FastQ (plain text or gzipped)
- or read a set of files (still using the same Bank!)
- convert that Bank to a De Bruijn graph (Graph)
- navigate through the Graph (Node)

all of that directly using the Python Programming Language.

Documentation
=============

`Jump to the wiki <https://github.com/GATB/pyGATB/wiki>`__ to review how
to install, use and make pyGATB Python3 compliant codes.

License
=======

pyGATB and GATB-Core are free softwares; you can redistribute it and/or
modify it under the `Affero GPL v3
license <http://www.gnu.org/licenses/agpl-3.0.en.html>`__.


.. |_| unicode:: 0x00A0
   :trim:
.. |License: Affero-GPL| image:: https://img.shields.io/:license-Affero--GPL-blue.svg
   :target: https://www.gnu.org/licenses/agpl-3.0.en.html
.. |Platform: C++11 Python3| image:: https://img.shields.io/badge/platform-c++/11_Python--3-yellow.svg
   :target: https://isocpp.org/wiki/faq/cpp11
.. |Run on Linux-Mac OSX| image:: https://img.shields.io/badge/run_on-Linux--Mac_OSX-yellowgreen.svg
.. |Build Status OSX| image:: https://ci.inria.fr/gatb-core/view/pyGATB/job/pyGATB-build-macos-10.9.5-gcc-4.2.1/badge/icon
   :target: https://ci.inria.fr/gatb-core/view/pyGATB/job/pyGATB-build-macos-10.9.5-gcc-4.2.1/
.. |Build Status Ubuntu| image:: https://ci.inria.fr/gatb-core/view/pyGATB/job/pyGATB-build-ubuntu16-gcc-5.4/badge/icon
   :target: https://ci.inria.fr/gatb-core/view/pyGATB/job/pyGATB-build-ubuntu16-gcc-5.4/
