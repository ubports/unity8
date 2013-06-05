#!/usr/bin/python
# Copyright 2013 Canonical Ltd.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation; version 3.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import os, subprocess
from bzrlib import branch, errors
from bzrlib.urlutils import dirname, local_path_from_url

def execute_makecheck(local_branch, master_branch, old_revision_number, old_revision_id, future_revision_number, future_revision_id, tree_delta, future_tree):
    if not master_branch.basis_tree().has_filename("Shell.qml"):
        return

    os.chdir(local_path_from_url(master_branch.base))

    print "Executing 'make check'.."
    if (subprocess.call("make check", shell=True) != 0):
        raise errors.BzrError("Unit tests failed, fix them before committing!")

    print "Executing 'make qmluitests'.."
    if (subprocess.call("make qmluitests", shell=True) != 0):
        raise errors.BzrError("QML UI tests failed, fix them before committing!")

branch.Branch.hooks.install_named_hook('pre_commit', execute_makecheck, 'make check pre-commit')
