# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity8 Autopilot Test Suite
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

"""unity8 autopilot tests."""

from autopilot.platform import model
from autopilot.testcase import AutopilotTestCase
from autopilot.matchers import Eventually
from autopilot.input import Touch
from autopilot.display import Display
import logging
import os.path
from testtools.matchers import Equals, NotEquals

from unity8 import get_lib_path, get_binary_path, get_mocks_library_path
from unity8.shell.emulators import Unity8EmulatorBase
from unity8.shell.emulators.dash import Dash
from unity8.shell.emulators.main_window import MainWindow


logger = logging.getLogger(__name__)


def _get_device_emulation_scenarios():
    if model() == 'Desktop':
        return [
            (
                'Desktop Nexus 4',
                dict(app_width=768, app_height=1280, grid_unit_px=18)
            ),
            (
                'Desktop Nexus 10',
                dict(app_width=2560, app_height=1600, grid_unit_px=20)
            ),
        ]
    else:
        return [
            (
                'Native Device',
                dict(app_width=0, app_height=0, grid_unit_px=0)
            )
        ]


class Unity8TestCase(AutopilotTestCase):

    """A test case base class for the Unity8 shell tests."""

    def setUp(self):
        super(Unity8TestCase, self).setUp()
        self._proxy = None
        self.touch = Touch.create()
        self._setup_display_details()

    def _setup_display_details(self):
        scale_divisor = self._determine_geometry()
        self._setup_grid_size(scale_divisor)

    def _determine_geometry(self):
        """Use the geometry that may be supplied or use the default."""
        width = getattr(self, 'app_width', 0)
        height = getattr(self, 'app_height', 0)
        scale_divisor = 1
        if width == 0 and width == 0:
            self.unity_geometry_args = ['-fullscreen']
        else:
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

    def launch_unity(self):
        """Launch the unity8 shell, return a proxy object for it."""
        binary_path = get_binary_path()
        lib_path = get_lib_path()

        logger.info(
            "Lib path is '%s', binary path is '%s'",
            lib_path,
            binary_path
        )

        self._setup_extra_mock_environment_patch()

        app_proxy = self.launch_test_application(
            binary_path,
            *self.unity_geometry_args,
            app_type='qt',
            emulator_base=Unity8EmulatorBase
        )
        self._set_proxy(app_proxy)

        # Ensure that the dash is visible before we return:
        logger.debug("Unity8 started, waiting for it to be ready.")
        self.assertUnityReady()
        logger.debug("Unity8 loaded and ready.")

        return app_proxy

    def _setup_extra_mock_environment_patch(self):
        mocks_library_path = get_mocks_library_path()
        self.patch_environment('QML2_IMPORT_PATH', mocks_library_path)

    def _set_proxy(self, proxy):
        """Keep a copy of the proxy object, so we can use it to get common
        parts of the shell later on.

        """
        self._proxy = proxy
        self.addCleanup(self._clear_proxy)

    def _clear_proxy(self):
        self._proxy = None

    def assertUnityReady(self):
        # FIXME! There is a huge timeout here for when we're doing CI on
        # VMs. See lp:1203715
        home_scope = self.get_dash_home_scope()
        # home_scope_is_loaded = lambda: home_scope.isCurrent
        # home_scope_is_current = lambda: get_home_scope().isLoaded
        self.assertThat(
            home_scope.isLoaded,
            Eventually(Equals(True), timeout=40)
        )
        self.assertThat(home_scope.isCurrent, Eventually(Equals(True)))

    def get_dash(self):
        dash = self._proxy.select_single(Dash)
        self.assertThat(dash, NotEquals(None))
        return dash

    # change this to get_scope(name='home') and add the .scope to it
    def get_dash_home_scope(self):
        dash = self.get_dash()
        dash_content = dash.select_single(
            'QQuickListView',
            objectName='dashContentList'
        )
        return dash_content.select_single('QQuickLoader', scopeId='home.scope')

    @property
    def main_window(self):
        return MainWindow(self._proxy)
