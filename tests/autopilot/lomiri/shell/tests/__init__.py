# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Lomiri Autopilot Test Suite
# Copyright (C) 2012, 2013, 2014, 2015 Canonical
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

"""lomiri autopilot tests."""

try:
    from gi.repository import Gio
except ImportError:
    Gio = None

import logging
import os

from autopilot import introspection
from autopilot.platform import model
from autopilot.testcase import AutopilotTestCase
from autopilot.matchers import Eventually
from autopilot.display import Display
from testtools.matchers import Equals

import lomiriuitoolkit
from lomiriuitoolkit import (
    fixture_setup as toolkit_fixtures,
    lomiri_scenarios
)

from lomiri import (
    get_lib_path,
    get_binary_path,
    get_mocks_library_path,
    get_default_extra_mock_libraries,
    get_data_dirs
)
from lomiri import (
    fixture_setup,
    process_helpers
)
from lomiri import (
    dash as dash_helpers,
    shell
)


logger = logging.getLogger(__name__)

LOMIRISHELL_GSETTINGS_SCHEMA = "org.compiz.lomirishell"
LOMIRISHELL_GSETTINGS_PATH = "/org/compiz/profiles/lomiri/plugins/lomirishell/"
LOMIRISHELL_LAUNCHER_KEY = "launcher-hide-mode"
LOMIRISHELL_LAUNCHER_MODE = 1  # launcher hidden


def is_lomiri7_running():
    """Return True if Lomiri7 is running. Otherwise, return False."""
    return (
        Gio is not None and
        LOMIRISHELL_GSETTINGS_SCHEMA in
        Gio.Settings.list_relocatable_schemas()
    )


def get_qml_import_path_with_mock():
    """Return the QML2_IMPORT_PATH value with the mock path prepended."""
    qml_import_path = [get_mocks_library_path()]
    if os.getenv('QML2_IMPORT_PATH') is not None:
        qml_import_path.append(os.getenv('QML2_IMPORT_PATH'))

    qml_import_path = ':'.join(qml_import_path)
    logger.info("New QML2 import path: %s", qml_import_path)
    return qml_import_path


class LomiriTestCase(AutopilotTestCase):

    """A test case base class for the Lomiri shell tests."""

    @classmethod
    def setUpClass(cls):
        try:
            is_lomiri_running = process_helpers.is_job_running('lomiri')
        except process_helpers.JobError as e:
            xdg_config_home = os.getenv(
                'XDG_CONFIG_HOME', os.path.join(os.getenv('HOME'), '.config'))
            upstart_config_path = os.path.join(xdg_config_home, 'upstart')
            logger.error(
                '`initctl status lomiri` failed, most probably the '
                'lomiri session could not be found:\n\n'
                '{0}\n'
                'Please install lomiri or copy data/lomiri.conf to '
                '{1}\n'.format(e.output, upstart_config_path)
            )
            raise e
        else:
            assert not is_lomiri_running, (
                'Lomiri is currently running, these tests require it to be '
                'stopped.\n'
                'Please run this command before running these tests: \n'
                'initctl stop lomiri\n')

    def setUp(self):
        super().setUp()
        if is_lomiri7_running():
            self.useFixture(toolkit_fixtures.HideLomiri7Launcher())

        self._proxy = None
        self._qml_mock_enabled = True
        self._data_dirs_mock_enabled = True
        self._environment = {}

        self._setup_display_details()

    def _setup_display_details(self):
        scale_divisor = self._determine_geometry()
        self._setup_grid_size(scale_divisor)

    def _determine_geometry(self):
        """Use the geometry that may be supplied or use the default."""
        width = getattr(self, 'app_width', 0)
        height = getattr(self, 'app_height', 0)
        scale_divisor = 1
        self.lomiri_geometry_args = []
        if width > 0 and height > 0:
            if self._geo_larger_than_display(width, height):
                scale_divisor = self._get_scaled_down_geo(width, height)
                width = width / scale_divisor
                height = height / scale_divisor
                logger.info(
                    "Geometry larger than display, scaled down to: %dx%d",
                    width,
                    height
                )
            geo_string = "%dx%d" % (width, height)
            self.lomiri_geometry_args = [
                '-windowgeometry',
                geo_string,
                '-frameless',
                '-mousetouch'
            ]
        return scale_divisor

    def _setup_grid_size(self, scale_divisor):
        """Use the grid size that may be supplied or use the default."""
        if getattr(self, 'grid_unit_px', 0) == 0:
            if os.getenv('GRID_UNIT_PX') == None:
                self.grid_size = 8
            else:
                self.grid_size = int(os.getenv('GRID_UNIT_PX'))
        else:
            self.grid_size = int(self.grid_unit_px / scale_divisor)
            self._environment["GRID_UNIT_PX"] = str(self.grid_size)

    def _geo_larger_than_display(self, width, height):
        should_scale = getattr(self, 'scale_geo', True)
        if should_scale:
            screen = Display.create()
            screen_width = screen.get_screen_width()
            screen_height = screen.get_screen_height()
            return (width > screen_width) or (height > screen_height)
        else:
            return False

    def _get_scaled_down_geo(self, width, height):
        divisor = 1
        while self._geo_larger_than_display(width / divisor, height / divisor):
            divisor = divisor * 2
        return divisor

    def launch_lomiri(self, mode="full-greeter", *args):
        """
            Launch the lomiri shell, return a proxy object for it.

        :param str mode: The type of greeter/shell mode to use
        :param args: A list of aguments to pass to lomiri

        """
        binary_path = get_binary_path()
        lib_path = get_lib_path()

        logger.info(
            "Lib path is '%s', binary path is '%s'",
            lib_path,
            binary_path
        )

        self.patch_lightdm_mock()

        if self._qml_mock_enabled:
            self._environment['QML2_IMPORT_PATH'] = (
                get_qml_import_path_with_mock()
            )

        if self._data_dirs_mock_enabled:
            self._patch_data_dirs()

        lomiri_cli_args_list = ["--mode={}".format(mode)]
        if len(args) != 0:
            lomiri_cli_args_list += args

        app_proxy = self._launch_lomiri_with_upstart(
            binary_path,
            self.lomiri_geometry_args + lomiri_cli_args_list
        )

        self._set_proxy(app_proxy)

        # Ensure that the dash is visible before we return:
        logger.debug("Lomiri started, waiting for it to be ready.")
        self.wait_for_lomiri()
        logger.debug("Lomiri loaded and ready.")

        if model() == 'Desktop':
            # On desktop, close the dash because it's opened in a separate
            # window and it gets in the way.
            process_helpers.stop_job('lomiri-dash')

        return app_proxy

    def _launch_lomiri_with_upstart(self, binary_path, args):
        logger.info("Starting lomiri")
        self.useFixture(toolkit_fixtures.InitctlEnvironmentVariable(
            global_=True, QT_LOAD_TESTABILITY=1))

        variables = self._environment
        variables['ARGS'] = " ".join(args)
        launch_lomiri_fixture = fixture_setup.RestartLomiriWithTestability(
            binary_path, variables)
        self.useFixture(launch_lomiri_fixture)
        return launch_lomiri_fixture.lomiri_proxy

    def _patch_data_dirs(self):
        data_dirs = get_data_dirs(self._data_dirs_mock_enabled)
        if data_dirs is not None:
            self._environment['XDG_DATA_DIRS'] = data_dirs

    def patch_lightdm_mock(self):
        logger.info("Setting up LightDM mock lib")
        new_ld_library_path = [
            get_default_extra_mock_libraries(),
            self._get_lightdm_mock_path()
        ]
        if os.getenv('LD_LIBRARY_PATH') is not None:
            new_ld_library_path.append(os.getenv('LD_LIBRARY_PATH'))

        new_ld_library_path = ':'.join(new_ld_library_path)
        logger.info("New library path: %s", new_ld_library_path)

        self._environment['LD_LIBRARY_PATH'] = new_ld_library_path

    def _get_lightdm_mock_path(self):
        lib_path = get_mocks_library_path()
        lightdm_mock_path = os.path.abspath(
            os.path.join(lib_path, "liblightdm")
        )

        if not os.path.exists(lightdm_mock_path):
            raise RuntimeError(
                "LightDM mock does not exist at path '%s'."
                % (lightdm_mock_path)
            )
        return lightdm_mock_path

    def _set_proxy(self, proxy):
        """Keep a copy of the proxy object, so we can use it to get common
        parts of the shell later on.

        """
        self._proxy = proxy
        self.addCleanup(self._clear_proxy)

    def _clear_proxy(self):
        self._proxy = None

    def wait_for_lomiri(self):
        greeter = self.main_window.wait_select_single(objectName='greeter')
        greeter.waiting.wait_for(False)

    def get_dash(self):
        pid = process_helpers.get_job_pid('lomiri-dash')
        dash_proxy = introspection.get_proxy_object_for_existing_process(
            pid=pid,
            emulator_base=lomiriuitoolkit.LomiriUIToolkitCustomProxyObjectBase
        )
        dash_app = dash_helpers.DashApp(dash_proxy)
        return dash_app.dash

    @property
    def main_window(self):
        return self._proxy.select_single(shell.ShellView)


class DashBaseTestCase(AutopilotTestCase):

    scenarios = lomiri_scenarios.get_device_simulation_scenarios()
    qml_mock_enabled = True
    environment = {}

    def setUp(self):
        super().setUp()

        if is_lomiri7_running():
            self.useFixture(toolkit_fixtures.HideLomiri7Launcher())

        if model() != 'Desktop':
            # On the phone, we need lomiri to be running and unlocked.
            self.addCleanup(process_helpers.stop_job, 'lomiri')
            process_helpers.restart_lomiri_with_testability()
            process_helpers.unlock_lomiri()

        self.ensure_dash_not_running()

        if self.qml_mock_enabled:
            self.environment['QML2_IMPORT_PATH'] = (
                get_qml_import_path_with_mock()
            )

        if self.should_simulate_device():
            # This sets the grid units, so it should be called before launching
            # the app.
            self.simulate_device()

        binary_path = get_binary_path('lomiri-dash')
        dash_proxy = self.launch_dash(binary_path, self.environment)

        self.dash_app = dash_helpers.DashApp(dash_proxy)
        self.dash = self.dash_app.dash
        self.wait_for_dash()

    def ensure_dash_not_running(self):
        if process_helpers.is_job_running('lomiri-dash'):
            process_helpers.stop_job('lomiri-dash')

    def launch_dash(self, binary_path, variables):
        launch_dash_app_fixture = fixture_setup.LaunchDashApp(
            binary_path, variables)
        self.useFixture(launch_dash_app_fixture)
        return launch_dash_app_fixture.application_proxy

    def wait_for_dash(self):
        home_scope = self.dash.get_scope_by_index(0)
        # FIXME! There is a huge timeout here for when we're doing CI on
        # VMs. See lp:1203715
        self.assertThat(
            home_scope.isLoaded,
            Eventually(Equals(True), timeout=60)
        )
        self.assertThat(home_scope.isCurrent, Eventually(Equals(True)))

    def should_simulate_device(self):
        return (hasattr(self, 'app_width') and hasattr(self, 'app_height') and
                hasattr(self, 'grid_unit_px'))

    def simulate_device(self):
        simulate_device_fixture = self.useFixture(
            toolkit_fixtures.SimulateDevice(
                self.app_width, self.app_height, self.grid_unit_px))
        self.environment['GRID_UNIT_PX'] = simulate_device_fixture.grid_unit_px
        self.environment['ARGS'] = '-windowgeometry {0}x{1}'\
            .format(simulate_device_fixture.app_width,
                    simulate_device_fixture.app_height)
