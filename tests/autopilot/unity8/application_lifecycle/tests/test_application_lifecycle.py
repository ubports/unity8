# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity Autopilot Test Suite
# Copyright (C) 2013 Canonical
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

"""Tests for the application lifecycle."""

from __future__ import absolute_import

import logging
from textwrap import dedent
import os
from tempfile import mktemp

from autopilot.platform import model

from unity8.shell.tests import UnityTestCase, _get_device_emulation_scenarios

from testtools.matchers import Equals


logger = logging.getLogger(__name__)


class ApplicationLifecycleTests(UnityTestCase):

    scenarios = _get_device_emulation_scenarios()

    def setUp(self):
        super(ApplicationLifecycleTests, self).setUp()
        if model() == "Desktop":
            self.skipTest("Test must be run on a device.")

    def swipe_from_right(self):
        x, y, w, h = self.main_window.globalRect
        start_x = w
        start_y = int(h / 2)
        end_x = int(w / 2)
        end_y = start_y

        self.touch.drag(start_x, start_y, end_x, end_y)

    def _start_qml_script(self, script_contents):
        """Launch a qml script."""
        qml_path = mktemp(suffix='.qml')
        open(qml_path, 'w').write(script_contents)
        self.addCleanup(os.remove, qml_path)

        desktop_file = self._get_dummy_desktop_file()

        return self.launch_test_application(
            "qmlscene",
            qml_path,
            "--desktop_file_hint=%s" % desktop_file,
            app_type='qt',
        )

    def _get_dummy_desktop_file(self):
        """Create a temp desktop file with app name *app_name*.

        Returns the full path to the file.

        """
        file_path = mktemp(suffix='.desktop')
        script_contents = dedent(
"""[Desktop Entry]
Name=App1
Comment=My project description
Exec=true
Icon=qmlscene
Terminal=false
Type=Application
X-Ubuntu-Touch=true""")
        open(file_path, 'w').write(script_contents)
        self.addCleanup(os.remove, file_path)

        print ">>> file path: ", file_path
        return file_path

    # def _get_qml_script(self, title="Test App"):
    #     return dedent("""
    #         import QtQuick 2.0
    #         import Ubuntu.Components 0.1

    #         Page {
    #             title: "%s"
    #             width: units.gu(48)
    #             height: units.gu(60)
    #         }
    #     """ % title)
    def _get_qml_script(self, name="TestApp"):
        return dedent("""
            import QtQuick 2.0
            import Ubuntu.Components 0.1

            Rectangle {
                objectName: "%s"
                color: "lightblue"
                Text {
                    text: "%s"
                    font.pixelSize: units.gu(8)
                }
            }
        """ % (name, name))

    def test_can_launch_application(self):
        """must be able to launch and interact with an application."""
        self.launch_unity()
        self.main_window.get_greeter().swipe()

        #import pdb; pdb.set_trace()

        test_qml = self._get_qml_script()
        app = self._start_qml_script(test_qml)
        main_window = app.select_single("Page")

        self.assertThat(main_window.title, Equals("Test App"))
        self.assertThat(main_window.visible, Equals(True))

    def test_can_launch_multiple_applications(self):
        """A second application launched must be usable."""
        self.launch_unity()
        self.main_window.get_greeter().swipe()
        first_app = self._start_qml_script(self._get_qml_script("App 1"))
        second_app = self._start_qml_script(self._get_qml_script("App 2"))

        first_main_window = first_app.select_single("Page")
        second_main_window = second_app.select_single("Page")

        self.assertThat(first_main_window.visible, Equals(False))

        self.assertThat(second_main_window.title, Equals("App 2"))
        self.assertThat(second_main_window.visible, Equals(True))

    def test_app_moves_from_unfocused_to_focused(self):
        """An application that is in the unfocused state must be able to be
        brought back to the focused state.

        """
        self.launch_unity()
        self.main_window.get_greeter().swipe()
        first_app = self._start_qml_script(self._get_qml_script("App 1"))
        self._start_qml_script(self._get_qml_script("App 2"))

        first_main_window = first_app.select_single("Page")

        self.swipe_from_right()

        self.assertThat(first_main_window.title, Equals("App 1"))
        self.assertThat(first_main_window.visible, Equals(True))

        # interact with it . . .
        # self.assertThat(first_main_window.visible, Equals(True))
