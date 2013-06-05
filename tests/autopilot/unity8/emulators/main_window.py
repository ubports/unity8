# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

class MainWindow(object):
    """An emulator class that makes it easy to interact with the shell"""

    def __init__(self, app):
        self.app = app

    def get_qml_view(self):
        """Get the main QML view"""
        return self.app.select_single("QQuickView")

    def get_greeter(self):
        return self.app.select_single("Greeter")

    def get_greeter_content_loader(self):
        return self.app.select_single("QQuickLoader", objectName="greeterContentLoader")

    def get_login_loader(self):
        return self.app.select_single("QQuickLoader", objectName="loginLoader")

    def get_login_list(self):
        return self.app.select_single("LoginList")

    def get_hud(self):
        return self.app.select_single("Hud")

    def get_hud_showable(self):
        return self.app.select_single("Showable", objectName="hudShowable")

    def get_hud_show_button(self):
        return self.app.select_single("HudButton")

    def get_dash(self):
        return self.app.select_single("Dash")

    def get_dash_home_applications_grid(self):
        return self.app.select_single("ApplicationsFilterGrid", objectName="dashHomeApplicationsGrid")

    def get_bottombar(self):
        return self.app.select_single("Bottombar")

    def get_launcher(self):
        return self.app.select_single("Launcher")
