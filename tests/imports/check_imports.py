#! /usr/bin/env python3

#
# Copyright (C) 2015 Canonical Ltd
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

#
# Little helper program to test that all source files import
# versions we want
#
# Usage: check_imports.py directory [ignore_prefix]
#
# The directory specifies the (recursive) location of the source files. Any
# files with a path that starts with ignore_prefix are not checked. This is
# useful to exclude files that are generated into the build directory.
#
# See the file_pat definition below for a list of files that are checked.
#

from __future__ import print_function

import argparse
import os
import re
import sys


# Print msg on stderr, preceded by program name and followed by newline
def error(msg):
    print(os.path.basename(sys.argv[0]) + ": " + msg, file=sys.stderr)


# Function to raise errors encountered by os.walk
def raise_error(e):
    raise e

# Qt Quick patterns
# If you increase this make sure you increase
# the Qt version in debian/control and in CMakeLists.txt
quick_pat = re.compile(r'.*import QtQuick.*$')
quick_good_pat = re.compile(r'.*import QtQuick 2\.4.*$')
quick_layouts_good_pat = re.compile(r'.*import QtQuick.Layouts 1\.1.*$')
quick_window_good_pat = re.compile(r'.*import QtQuick.Window 2\.2.*$')

# Ubuntu Components patterns
ubuntu_components_pat = re.compile(r'.*import Ubuntu.Components.*')
ubuntu_good_components_pat = re.compile(r'.*import Ubuntu.Components.*1\.3.*')

def scan_for_bad_import(file_path, all_pat, good_pats):
    errors = []
    with open(file_path, 'rt', encoding='utf-8') as ifile:
        for lino, line in enumerate(ifile, start=1):
            if all_pat.match(line):
                good_found = False
                for good_pat in good_pats:
                    if good_pat.match(line):
                        good_found = True
                if not good_found:
                    errors.append(lino)
    if 0 < len(errors) <= 10:
        if len(errors) > 1:
            plural = 's'
        else:
            plural = ''
        print(
            "%s: bad import version in line%s %s" % (
                file_path, plural, ", ".join((str(i) for i in errors))))
    elif errors:
        print("%s: bad import version in multiple lines" % file_path)
    return bool(errors)

# Parse args

parser = argparse.ArgumentParser(
    description='Test that source files contain the wanted import version.')
parser.add_argument(
    'dir', nargs=1,
    help='The directory to (recursively) search for source files')
parser.add_argument(
    'ignore_prefix', nargs='?', default=None,
    help='Ignore source files with a path that starts with the given prefix.')
args = parser.parse_args()

# Files we want to check for import version.

file_pat = (
    r'(.*\.(js|qml)$)')
pat = re.compile(file_pat)

# Find all the files with matching file extension in the specified
# directory and check them

directory = os.path.abspath(args.dir[0])
ignore = args.ignore_prefix and os.path.abspath(args.ignore_prefix) or None

found_bad_import = False
try:
    for root, dirs, files in os.walk(directory, onerror=raise_error):
        for file in files:
            path = os.path.join(root, file)
            if not (ignore and path.startswith(ignore)) and pat.match(file):
                quick_good_pats = [quick_good_pat, quick_layouts_good_pat, quick_window_good_pat]
                if scan_for_bad_import(path, quick_pat, quick_good_pats):
                    found_bad_import = True
                if scan_for_bad_import(path, ubuntu_components_pat, [ubuntu_good_components_pat]):
                    found_bad_import = True

except OSError as e:
    error("cannot create file list for \"" + dir + "\": " + e.strerror)
    sys.exit(1)

if found_bad_import:
    sys.exit(1)
