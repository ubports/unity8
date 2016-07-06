# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity Autopilot Test Suite
# Copyright (C) 2015 Canonical
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

from unity8.greeter.tests import GreeterTestCase


class GreeterArgsTest(GreeterTestCase):

    DEFAULT_SHELL_MODE = 'full-greeter'
    NONEXISTENT_MODE = 'non-existent-mode'

    def test_full_greeter_mode(self):
        unity_proxy = self.launch_unity(mode='full-greeter')
        shell = self.get_shell(unity_proxy)
        self.assertTrue(shell.mode == 'full-greeter')

    def test_full_shell_mode(self):
        unity_proxy = self.launch_unity(mode='full-shell')
        shell = self.get_shell(unity_proxy)
        self.assertTrue(shell.mode == 'full-shell')

    def test_nonexistent_mode(self):
        unity_proxy = self.launch_unity(mode=self.NONEXISTENT_MODE)
        shell = self.get_shell(unity_proxy)
        self.assertTrue(shell.mode == self.DEFAULT_SHELL_MODE,
                        "Shell mode was {} but should have been {}"
                        .format(shell.mode,
                                self.DEFAULT_SHELL_MODE))

    def test_shell_mode(self):
        unity_proxy = self.launch_unity(mode='shell')
        shell = self.get_shell(unity_proxy)
        self.assertTrue(shell.mode == 'shell')
