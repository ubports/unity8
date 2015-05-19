import os
import sysconfig

from unity8.settings_wizard import fixture_setup
from unity8.settings_wizard.emulators.settings_wizard import Wizard
from unity8.settings_wizard.phonesim_manager import PhonesimManager
from unity8.shell import tests

DEFAULT_LANGUAGE = 'English (United States)'
DEFAULT_PHONESIM_CONFIG_FILE = '/usr/share/phonesim/default.xml'
DEFAULT_SECURITY_METHOD = 'Passcode'

import pdb


class SkipThroughSettingsWizardTestCase(tests.UnityTestCase):
    """ Autopilot test for completing settings wizard """

    def setUp(self):
        super().setUp()
        phonesim_datadir = os.getenv('INDICATOR_NETWORK_PHONESIM_DATA')
        if phonesim_datadir is None:
            phonesim_datadir = sysconfig.get_config_var('datarootdir') + \
                '/indicator-network/phonesim'

        sims = [('sim1',
                 23456,
                 phonesim_datadir + '/pin-unlock.xml')]
        self.phonesim_manager = PhonesimManager(sims)
        self.wizard_helper = self.useFixture(
            fixture_setup.SettingsWizard(True))
        pdb.set_trace()
        self.phonesim_manager.start_phonesim_processes()
        self.phonesim_manager.remove_all_ofono()
        self.phonesim_manager.add_ofono('sim1')
        self.phonesim_manager.power_on('sim1')
        self.phonesim_manager.power_off('sim1')
        pdb.set_trace()
        self.unity = self.launch_unity()
        self.wizard = self._get_settings_wizard()

    def tearDown(self):
        self.phonesim_manager.shutdown()

    def _get_settings_wizard(self):
        return self.unity.wait_select_single(Wizard)

    def _test_language_page(self):
        """ Get the language page, check the default language and continue """
        language_page = self.wizard.get_language_page()
        default_selection = language_page.get_selected_language()
        self.assertEqual(default_selection, DEFAULT_LANGUAGE)
        return language_page.continue_()

    def _test_password_page(self, password_page):
        """ Check default selection for password type and change
        password type to swipe to keep this test as uncomplicated
        as possible """
        default_selection = password_page.get_selected_security_option()
        self.assertEqual(default_selection, DEFAULT_SECURITY_METHOD)
        password_page.select_security_option('Swipe')
        return password_page.continue_()

    def test_skipping_through_wizard(self):
        """ Most basic test of the settings wizard. Skip all skipable pages """
        # FIXME for now, assume there is no SIM card in the phone
        # A mock should allow testing both situations later
        sim_inserted, next_page = self._test_language_page()
        password_page = next_page.skip()
        wifi_connect_page = self._test_password_page(password_page)
        # FIXME This _will_ not work without a mock as the behavior is
        # dependent on weather or not there is a connection to a wifi network
        reporting_page = wifi_connect_page.skip()
        finish_page = reporting_page.continue_()
        finish_page.finish()
