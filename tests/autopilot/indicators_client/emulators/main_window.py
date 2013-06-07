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

    def get_indicators_client(self):
        return self.app.select_single("IndicatorsClient")

    def get_page_stack(self):
        """Get the page stack"""
        return self.app.select_single("PageStack")

    def get_power_menu(self):
        """Get the power menu from the list"""
        return self.app.select_single("BasicMenu", objectName="indicator-power");
