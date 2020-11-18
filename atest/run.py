#!/usr/bin/env python

"""usage: python atest/run.py <test_suite_path>"

    Examples:
    Running all the tests with Robot:
    python atest/run.py atest

    Results are found in path 'atest/results/'
"""
import sys

from os.path import abspath, dirname, join
from robot import run_cli, rebot
from robotstatuschecker import process_output

CURDIR = dirname(abspath(__file__))
OUTPUT_ROOT = join(CURDIR, 'results')
JAR_PATH = join(CURDIR, '..', 'lib')

sys.path.append(join(CURDIR, '..', 'src'))

COMMON_OPTS = ('--log', 'NONE', '--report', 'NONE')


def atests(*opts):
    python(*opts)
    process_output(join(OUTPUT_ROOT, 'output.xml'))
    return rebot(join(OUTPUT_ROOT, 'output.xml'), outputdir=OUTPUT_ROOT)


def python(*opts):
    try:
        run_cli(['--outputdir', OUTPUT_ROOT]
                + list(COMMON_OPTS + opts))
    except SystemExit:
        pass


if __name__ == '__main__':
    if len(sys.argv) == 1 or '--help' in sys.argv:
        print(__doc__)
        rc = 251
    else:
        rc = atests(*sys.argv[1:])
    print("\nAfter status check there were %s failures." % rc)
    sys.exit(rc)
