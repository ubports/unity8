from unity8.settings_wizard import fixture_setup
from unity8.settings_wizard.emulators.settings_wizard import Wizard
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

    def _test_wifi_connect_page(self, wifi_connect_page):
        return wifi_connect_page.advance_page()

    def test_skipping_through_wizard(self):
        """ Most basic test of the settings wizard. Skip all skipable pages """
        sim_inserted, next_page = self._test_language_page()
        if sim_inserted:
            password_page = next_page
        else:
            password_page = next_page.skip()
        wifi_connect_page = self._test_password_page(password_page)
        reporting_page = self._test_wifi_connect_page(wifi_connect_page)
        finish_page = self._test_reporting_page(reporting_page)
        finish_page.finish()
        self.assertFalse(
            self.wizard_helper.is_settings_wizard_enabled())
