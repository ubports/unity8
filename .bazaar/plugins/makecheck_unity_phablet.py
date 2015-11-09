#!/usr/bin/python
# Copyright 2013, 2014 Canonical Ltd.
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

import os
import subprocess
from bzrlib import branch
from bzrlib.urlutils import local_path_from_url


def execute_makecheck(
        local_branch, master_branch, old_revision_number, old_revision_id,
        future_revision_number, future_revision_id, tree_delta, future_tree):
    if not master_branch.basis_tree().has_filename("qml/Shell.qml"):
        return

    os.chdir(local_path_from_url(master_branch.base))

    print "Executing 'make -C builddir test'.."
    os.environ['CTEST_OUTPUT_ON_FAILURE'] = "1"
    if (subprocess.call("make -C builddir test", shell=True) != 0):

        print("\n\n*** Warning ***\n\n"
              "Basic tests failed. This commit will not pass continuous "
              "integration.")

        branch = local_branch or master_branch
        revision = branch.repository.get_revision(future_revision_id)
        msg_file = open('message.txt', 'w')
        msg_file.write(revision.message)
        msg_file.close()

        print("\n\nSaved commit message to $SRC_DIR/message.txt.")
        print("You can uncommit this revision, fix the tests and reuse your "
              "message running:\n\nbzr commit -F message.txt\n\n")
    elif os.path.isfile("message.txt"):
        os.remove("message.txt")

branch.Branch.hooks.install_named_hook(
    'pre_commit', execute_makecheck, 'make check pre-commit')
