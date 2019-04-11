#!/bin/sh

#
# Copyright (C) 2017 Canonical Ltd
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
# Check that, somewhere in the first 30 lines of each file, the string "Copyright" (case independent) appears.
# Print out a messsage for each file without a copyright notice and exit with non-zero status
# if any such file is found.
#

usage()
{
    echo "usage: check_copyright dir [ignore_dir]" >&2
    exit 2
}

[ $# -lt 1 ] && usage
[ $# -gt 2 ] && usage

# image files
ignore_pat="\\.sci$|\\.svg$|\\.png$|\\.jpg$"
# git/bzr files
ignore_pat="$ignore_pat|/\\.bzr/|\\.bzrignore$|\\.gitignore$|/\\.bazaar/Makefile$|/\\.bzr-builddeb/default\\.conf$"
# info files
ignore_pat="$ignore_pat|/README$|/CODING$|/LGPL_EXCEPTION\\.txt$"
# cmake files
ignore_pat="$ignore_pat|/CMakeLists\\.txt$|\\.cmake$"
# card creator test files
ignore_pat="$ignore_pat|/cardcreator/.*\\.res$|/cardcreator/.*\\.res\\.cardcreator$|/cardcreator/.*\\.tst$"
# project files
ignore_pat="$ignore_pat|/\\.project$|/\\.pydevproject$|/\\.settings/|/\\.crossbuilder/"
# test desktop files
ignore_pat="$ignore_pat|/tests/.*/.*\\.desktop$"
# xml files
ignore_pat="$ignore_pat|\\.xml$"
# /data/ files
ignore_pat="$ignore_pat|/data/.*\\.conf$|/data/.*\\.in|/data/.*\\.url-dispatcher$|/data/.*\\.pkla$"
# polkit files
ignore_pat="$ignore_pat|\\.pkla$"
# /debian/ files
ignore_pat="$ignore_pat|/debian/"
# qmldir files
ignore_pat="$ignore_pat|/qmldir$"
# Doxygen files
ignore_pat="$ignore_pat|/Doxyfile.in$"
# Wizard license files
ignore_pat="$ignore_pat|/Wizard/licenses/.*\\.html$"
# qrc files
ignore_pat="$ignore_pat|\\.qrc$"
# the doc devices.conf file
ignore_pat="$ignore_pat|/doc/devices\\.conf$"
# Jenkins configuration
ignore_pat="$ignore_pat|/Jenkinsfile"

#
# We don't use the -i option of licensecheck to add ignore_dir to the pattern because Jenkins creates directories
# with names that contain regex meta-characters, such as "." and "+". Instead, if ingnore_dir is set, we post-filter
# the output with grep -F, so we don't get false positives from licensecheck.
#

[ $# -eq 2 ] && ignore_dir="$2"

if [ -n "$ignore_dir" ]
then
    licensecheck -i "$ignore_pat" -r "$1" | grep -F "$ignore_dir" -v | grep 'No copyright'
else
    licensecheck -i "$ignore_pat" -r "$1" | grep 'No copyright'
fi

[ $? -eq 0 ] && exit 1

exit 0
