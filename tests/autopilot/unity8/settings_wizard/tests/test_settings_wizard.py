
from unity8.settings_wizard import fixture_setup
from unity8.settings_wizard.emulators.settings_wizard import Wizard
from unity8.shell import tests

DEFAULT_LANGUAGE = 'English (United States)'


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

    def test_skipping_through_wizard(self):
        """ Most basic test of the settings wizard. Skip all skipable pages """
        next_page = self._test_language_page()
