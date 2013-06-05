#! /usr/bin/env python3

#
# Copyright (C) 2013 Canonical Ltd
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
# Authored by: Michi Henning <michi.henning@canonical.com>
#

#
# Little helper program to test that source files do not contain trailing whitespace
# or tab indentation.
#
# Usage: check_whitespace.py directory [ignore_prefix]
#
# The directory specifies the (recursive) location of the source files. Any
# files with a path that starts with ignore_prefix are not checked. This is
# useful to exclude files that are generated into the build directory.
#
# See the file_pat definition below for a list of files that are checked.
#

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

# Scan lines in file_path for bad whitespace. For each file,
# print the line numbers that have whitespace issues

whitespace_pat = re.compile(r'.*[ \t]$')
tab_indent_pat = re.compile(r'^ *\t')

def scan_for_bad_whitespace(file_path):
    global tab_indent_pat, whitespace_pat
    errors = []
    newlines_at_end = 0
    with open(file_path, 'rt', encoding='utf-8') as ifile:
        for lino, line in enumerate(ifile, start=1):
            if whitespace_pat.match(line) or tab_indent_pat.match(line):
                errors.append(lino)
            if line == "\n":
                newlines_at_end += 1
            else:
                newlines_at_end = 0
    if 0 < len(errors) <= 10:
        if len(errors) > 1:
            plural = 's'
        else:
            plural = ''
        print("%s: bad whitespace in line%s %s" % (file_path, plural, ", ".join((str(i) for i in errors))))
    elif errors:
        print("%s: bad whitespace in multiple lines" % file_path)
    if newlines_at_end:
        print("%s: multiple new lines at end of file" % file_path)
    return bool(errors) or newlines_at_end

# Parse args

parser = argparse.ArgumentParser(description = 'Test that source files do not contain trailing whitespace.')
parser.add_argument('dir', nargs = 1, help = 'The directory to (recursively) search for source files')
parser.add_argument('ignore_prefix', nargs = '?', default=None,
                    help = 'Ignore source files with a path that starts with the given prefix.')
args = parser.parse_args()

# Files we want to check for trailing whitespace.

file_pat = r'(.*\.(c|cpp|h|hpp|hh|in|install|js|py|qml|sh)$)|(.*CMakeLists\.txt$)'
pat = re.compile(file_pat)

# Find all the files with matching file extension in the specified
# directory and check them for trailing whitespace.

directory = os.path.abspath(args.dir[0])
ignore = args.ignore_prefix and os.path.abspath(args.ignore_prefix) or None

found_whitespace = False
try:
    for root, dirs, files in os.walk(directory, onerror = raise_error):
        for file in files:
            path = os.path.join(root, file)
            if not (ignore and path.startswith(ignore)) and pat.match(file):
                if scan_for_bad_whitespace(path):
                    found_whitespace = True

except OSError as e:
    error("cannot create file list for \"" + dir + "\": " + e.strerror)
    sys.exit(1)

if found_whitespace:
    sys.exit(1)
