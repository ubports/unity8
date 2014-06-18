# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity Autopilot Test Suite
# Copyright (C) 2014 Canonical
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

"""Tests for system integration."""

import subprocess
import unittest

from autopilot import platform
from unity8.shell.tests import UnityTestCase, _get_device_emulation_scenarios


class SystemIntegrationTests(UnityTestCase):

    scenarios = _get_device_emulation_scenarios()

    @unittest.skipIf(
        platform.model() == "Desktop",
        "Test is broken on otto, see bug 1281634.")
    def test_networkmanager_integration(self):
        self.launch_unity()

        # invoke policykit to check permissions
        pid = subprocess.check_output(
            ["pidof", "-s", "unity8"], universal_newlines=True)
        subprocess.check_call(
            "pkcheck --action-id "
            "org.freedesktop.NetworkManager.enable-disable-network "
            "--process " + pid,
            shell=True)
