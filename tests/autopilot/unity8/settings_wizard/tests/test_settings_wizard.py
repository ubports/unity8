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

from unity8.settings_wizard import fixture_setup, Wizard
from unity8.shell import tests

DEFAULT_LANGUAGE = 'English (United States)'
DEFAULT_PHONESIM_CONFIG_FILE = '/usr/share/phonesim/default.xml'
DEFAULT_SECURITY_METHOD = 'Passcode'


class SkipThroughSettingsWizardTestCase(tests.UnityTestCase):
    """ Autopilot test for completing settings wizard """

    def setUp(self):
        super().setUp()
        self.wizard_helper = self.useFixture(
            fixture_setup.SettingsWizard(True))
        self.unity = self.launch_unity()
        self.wizard = self._get_settings_wizard()

    def _get_settings_wizard(self):
        return self.unity.wait_select_single(Wizard)

    def _test_language_page(self):
        """ Get the language page, check the default language and continue """
        language_page = self.wizard.get_language_page()
        default_selection = language_page.get_selected_language()
        self.assertEqual(default_selection, DEFAULT_LANGUAGE)
        return language_page.continue_()

    def _test_location_page(self, location_page):
        return location_page.continue_()

    def _test_password_page(self, password_page):
        """ Check default selection for password type and change
        password type to swipe to keep this test as uncomplicated
        as possible """
        default_selection = password_page.get_selected_security_option()
        self.assertEqual(default_selection, DEFAULT_SECURITY_METHOD)
        password_page.select_security_option('Swipe')
        return password_page.continue_()

    def _test_reporting_page(self, reporting_page):
        return reporting_page.continue_()

    def _test_sim_page(self, sim_page):
        return sim_page.skip()

    def _test_wifi_connect_page(self, wifi_connect_page):
        if wifi_connect_page.is_any_network_checked() or not \
           wifi_connect_page.is_any_network_found():
            return wifi_connect_page.continue_()
        else:
            return wifi_connect_page.skip()

    def test_skipping_through_wizard(self):
        """ Most basic test of the settings wizard. Skip all skipable pages """
        sim_inserted, next_page = self._test_language_page()
        if not sim_inserted:
            sim_page = next_page
            password_page = self._test_sim_page(sim_page)
        else:
            password_page = next_page
        wifi_connect_page = self._test_password_page(password_page)

        reporting_page = None
        locationPageEnabled, reportingPageEnabled, next_page = self._test_wifi_connect_page(wifi_connect_page)
        if locationPageEnabled:
            location_page = next_page
            if reportingPageEnabled:
                reporting_page = self._test_location_page(location_page)
            else:
                finish_page = next_page

        if reporting_page is not None:
            finish_page = self._test_reporting_page(reporting_page)
        else:
            finish_page = next_page

        finish_page.finish()
        self.assertFalse(
            self.wizard_helper.is_settings_wizard_enabled())
