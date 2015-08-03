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

"""Set up and clean up fixtures for the Unity SettingsWizard tests."""

import fixtures
import os

from os.path import expanduser


class SettingsWizard(fixtures.Fixture):
    WIZARD_FILE = expanduser("~") + \
        '/.config/ubuntu-system-settings/wizard-has-run'

    def __init__(self, enable):
        super().__init__()
        self.enable = enable

    def setUp(self):
        super().setUp()
        original_state = self.is_settings_wizard_enabled()
        self.addCleanup(self.set_settings_wizard, original_state)
        if self.enable != original_state:
            self.set_settings_wizard(self.enable)

    def is_settings_wizard_enabled(self):
        return not os.path.exists(self.WIZARD_FILE)

    def set_settings_wizard(self, enabled):
        if enabled:
            self.enable_settings_wizard()
        else:
            self.disable_settings_wizard()

    def enable_settings_wizard(self):
        if os.path.exists(self.WIZARD_FILE):
            os.remove(self.WIZARD_FILE)

    def disable_settings_wizard(self):
        if not os.path.exists(self.WIZARD_FILE):
            open(self.WIZARD_FILE, 'a').close()
