# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity Autopilot Test Suite
# Copyright (C) 2012-2013 Canonical
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

"""unity autopilot tests."""

try:
    from gi.repository import Gio
except ImportError:
    Gio = None

from autopilot.platform import model
from autopilot.testcase import AutopilotTestCase
from autopilot.matchers import Eventually
from autopilot.input import Touch
from autopilot.display import Display
import logging
import os.path
from testtools.matchers import Equals, NotEquals

from unity8 import (
    get_lib_path,
    get_binary_path,
    get_mocks_library_path,
    get_default_extra_mock_libraries,
)
from unity8.shell.emulators import UnityEmulatorBase
from unity8.shell.emulators.dash import Dash
from unity8.shell.emulators.main_window import MainWindow


logger = logging.getLogger(__name__)

UNITYSHELL_GSETTINGS_SCHEMA = "org.compiz.unityshell"
UNITYSHELL_GSETTINGS_PATH = "/org/compiz/profiles/unity/plugins/unityshell/"
UNITYSHELL_LAUNCHER_KEY = "launcher-hide-mode"
UNITYSHELL_LAUNCHER_MODE = 1 # launcher hidden

def _get_device_emulation_scenarios(devices='All'):
    nexus4 = ('Desktop Nexus 4',
              dict(app_width=768, app_height=1280, grid_unit_px=18))
    nexus10 = ('Desktop Nexus 10',
               dict(app_width=2560, app_height=1600, grid_unit_px=20))
    native = ('Native Device',
              dict(app_width=0, app_height=0, grid_unit_px=0))

    if model() == 'Desktop':
        if devices == 'All':
            return [nexus4, nexus10]
        elif devices == 'Nexus4':
            return [nexus4]
        elif devices == 'Nexus10':
            return [nexus10]
        else:
            raise RuntimeException('Unrecognized device-option "%s" passed.' % devices)
    else:
        return [native]

class UnityTestCase(AutopilotTestCase):

    """A test case base class for the Unity shell tests."""

    def setUp(self):
        super(UnityTestCase, self).setUp()
        if Gio is not None and UNITYSHELL_GSETTINGS_SCHEMA in Gio.Settings.list_relocatable_schemas():
            # Hide Unity launcher
            self._unityshell_schema = Gio.Settings.new_with_path(UNITYSHELL_GSETTINGS_SCHEMA, UNITYSHELL_GSETTINGS_PATH)
            self._launcher_hide_mode = self._unityshell_schema.get_int(UNITYSHELL_LAUNCHER_KEY)
            self._unityshell_schema.set_int(UNITYSHELL_LAUNCHER_KEY, UNITYSHELL_LAUNCHER_MODE)
            self.addCleanup(self._reset_launcher)

        self._proxy = None
        self._lightdm_mock_type = None
        self._qml_mock_enabled = True
        self.touch = Touch.create()
        self._setup_display_details()

    def _reset_launcher(self):
        """Reset Unity launcher hide mode"""
        self._unityshell_schema.set_int(UNITYSHELL_LAUNCHER_KEY, self._launcher_hide_mode)

    def _setup_display_details(self):
        scale_divisor = self._determine_geometry()
        self._setup_grid_size(scale_divisor)

    def _determine_geometry(self):
        """Use the geometry that may be supplied or use the default."""
        width = getattr(self, 'app_width', 0)
        height = getattr(self, 'app_height', 0)
        scale_divisor = 1
        self.unity_geometry_args = []
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
            self.unity_geometry_args = [
                '-geometry',
                geo_string,
                '-frameless',
                '-mousetouch'
            ]
        return scale_divisor

    def _setup_grid_size(self, scale_divisor):
        """Use the grid size that may be supplied or use the default."""
        if getattr(self, 'grid_unit_px', 0) == 0:
            self.grid_size = int(os.getenv('GRID_UNIT_PX'))
        else:
            self.grid_size = int(self.grid_unit_px / scale_divisor)
            self.patch_environment("GRID_UNIT_PX", str(self.grid_size))

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

    def launch_unity(self, **kwargs):
        """Launch the unity shell, return a proxy object for it."""
        binary_path = get_binary_path()
        lib_path = get_lib_path()

        logger.info(
            "Lib path is '%s', binary path is '%s'",
            lib_path,
            binary_path
        )

        if self._lightdm_mock_type is None:
            self.patch_lightdm_mock()

        if self._qml_mock_enabled:
            self._setup_extra_mock_environment_patch()

        # FIXME: we shouldn't be doing this
        # $MIR_SOCKET, fallback to $XDG_RUNTIME_DIR/mir_socket and /tmp/mir_socket as last resort
        try:
            os.unlink(os.getenv('MIR_SOCKET', os.path.join(os.getenv('XDG_RUNTIME_DIR', '/tmp'), "mir_socket")))
        except OSError:
            pass

        app_proxy = self.launch_test_application(
            binary_path,
            *self.unity_geometry_args,
            app_type='qt',
            emulator_base=UnityEmulatorBase,
            **kwargs
        )
        self._set_proxy(app_proxy)

        # Ensure that the dash is visible before we return:
        logger.debug("Unity started, waiting for it to be ready.")
        self.assertUnityReady()
        logger.debug("Unity loaded and ready.")

        return app_proxy

    def patch_lightdm_mock(self, mock_type='single'):
        self._lightdm_mock_type = mock_type
        logger.info("Setting up LightDM mock type '%s'", mock_type)
        new_ld_library_path = [
            get_default_extra_mock_libraries(),
            self._get_lightdm_mock_path(mock_type)
        ]
        if os.getenv('LD_LIBRARY_PATH') is not None:
            new_ld_library_path.append(os.getenv('LD_LIBRARY_PATH'))

        new_ld_library_path = ':'.join(new_ld_library_path)
        logger.info("New library path: %s", new_ld_library_path)

        self.patch_environment('LD_LIBRARY_PATH', new_ld_library_path)

    def _get_lightdm_mock_path(self, mock_type):
        lib_path = get_mocks_library_path()
        lightdm_mock_path = os.path.abspath(
            os.path.join(lib_path, "LightDM", mock_type)
        )

        if not os.path.exists(lightdm_mock_path):
            raise RuntimeError(
                "LightDM mock '%s' does not exist at path '%s'."
                % (mock_type, lightdm_mock_path)
            )
        return lightdm_mock_path

    def _setup_extra_mock_environment_patch(self):
        qml_import_path = [get_mocks_library_path()]
        if os.getenv('QML2_IMPORT_PATH') is not None:
            qml_import_path.append(os.getenv('QML2_IMPORT_PATH'))

        qml_import_path = ':'.join(qml_import_path)
        logger.info("New QML2 import path: %s", qml_import_path)
        self.patch_environment('QML2_IMPORT_PATH', qml_import_path)

    def _set_proxy(self, proxy):
        """Keep a copy of the proxy object, so we can use it to get common
        parts of the shell later on.

        """
        self._proxy = proxy
        self.addCleanup(self._clear_proxy)

    def _clear_proxy(self):
        self._proxy = None

    def assertUnityReady(self):
        dash = self.get_dash()
        home_scope = dash.get_scope('home')

        # FIXME! There is a huge timeout here for when we're doing CI on
        # VMs. See lp:1203715
        self.assertThat(
            home_scope.isLoaded,
            Eventually(Equals(True), timeout=60)
        )
        self.assertThat(home_scope.isCurrent, Eventually(Equals(True)))

    def get_dash(self):
        dash = self._proxy.select_single(Dash)
        self.assertThat(dash, NotEquals(None))
        return dash

    @property
    def main_window(self):
        return MainWindow(self._proxy)
