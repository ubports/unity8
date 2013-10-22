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


from unity8.shell.emulators.greeter import Greeter
from unity8.shell.emulators.hud import Hud
from unity8.shell.emulators.dash import Dash
from unity8.shell.emulators.launcher import Launcher


class MainWindow(object):
    """An emulator class that makes it easy to interact with the shell"""

    def __init__(self, app):
        self.app = app

    def get_qml_view(self):
        """Get the main QML view"""
        return self.app.select_single("QQuickView")

    def get_greeter(self):
        return self.app.select_single(Greeter)

    def get_greeter_content_loader(self):
        return self.app.select_single(
            "QQuickLoader",
            objectName="greeterContentLoader"
        )

    def get_login_loader(self):
        return self.app.select_single("QQuickLoader", objectName="loginLoader")

    def get_login_list(self):
        return self.app.select_single("LoginList")

    def get_hud(self):
        return self.app.select_single(Hud)

    def get_hud_showable(self):
        return self.app.select_single("Showable", objectName="hudShowable")

    def get_hud_show_button(self):
        return self.app.select_single("HudButton")

    def get_hud_edge_drag_area(self):
        return self.app.select_single(objectName="hudDragArea")

    def get_dash(self):
        return self.app.select_single(Dash)

    def get_dash_home_applications_grid(self):
        return self.app.select_single(
            "ApplicationsFilterGrid",
            objectName="dashHomeApplicationsGrid"
        )

    def get_bottombar(self):
        return self.app.select_single("Bottombar")

    def get_launcher(self):
        return self.app.select_single(Launcher)

    def get_pinPadLoader(self):
        return self.app.select_single(
            "QQuickLoader",
            objectName="pinPadLoader"
        )

    def get_pinPadButton(self, buttonId):
        return self.app.select_single(
            "PinPadButton",
            objectName="pinPadButton%i" % buttonId
        )

    def get_lockscreen(self):
        return self.app.select_single("Lockscreen")

    def get_pinentryField(self):
        return self.app.select_single(objectName="pinentryField")

    def get_indicator(self, indicator_name):
        return self.app.select_single(
            "Tab",
            objectName=indicator_name
        )
