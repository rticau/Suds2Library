#!/usr/bin/env python

import re
from os.path import join, dirname, abspath
from setuptools import setup

CURDIR = dirname(abspath(__file__))
REQUIREMENTS = ['robotframework', 'suds-py3']

with open(join(CURDIR, 'src', 'Suds2Library', 'version.py')) as f:
    VERSION = re.search("\nVERSION = '(.*)'", f.read()).group(1)

with open(join(CURDIR, 'README.rst')) as f:
    DESCRIPTION = f.read()

CLASSIFIERS = '''
Development Status :: 5 - Production/Stable
License :: OSI Approved :: Apache Software License
Operating System :: OS Independent
Programming Language :: Python :: 3.5
Programming Language :: Python :: 3.6
Programming Language :: Python :: 3.7
Programming Language :: Python :: 3.8
Topic :: Software Development :: Testing
'''.strip().splitlines()

setup(name='robotframework-suds2library',
      version=VERSION,
      description='Robot Framework test library for SOAP-based services.',
      long_description=DESCRIPTION,
      author='Mihai Parvu',
      author_email='mihai-catalin.parvu@nokia.com',
      url='https://github.com/rticau/Suds2Library',
      license='Apache License 2.0',
      keywords='robotframework testing testautomation soap suds web service',
      platforms='any',
      classifiers=CLASSIFIERS,
      install_requires=REQUIREMENTS,
      package_dir={'': 'src'},
      packages=['Suds2Library']
      )
