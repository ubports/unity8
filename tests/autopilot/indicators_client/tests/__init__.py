# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""qml-phone-shell autopilot tests."""

import os.path

from autopilot.testcase import AutopilotTestCase
from autopilot.matchers import Eventually
from autopilot.platform import model
from testtools.matchers import Equals

from indicators_client.emulators.main_window import MainWindow

class FormFactors(object):
    Phone, Tablet, Desktop = range(3)

class IndicatorsTestCase(AutopilotTestCase):

    """A common test case class that provides several useful methods for shell tests."""

    def setUp(self, geometry, grid_size):
        super(ShellTestCase, self).setUp()
        self.launch_test_local(geometry)

    def launch_test_local(self, geometry):
        os.environ['LD_LIBRARY_PATH'] = "../../../unity_build/build/lib"
        os.environ['QML2_IMPORT_PATH'] = "../../builddir/plugins:../../builddir/tests/mocks"
        self.app = self.launch_test_application(
            "../../builddir/plugins/IndicatorsClient/client/indicators-client")

    def skipWrapper(*args, **kwargs):
        pass

    def form_factor(self):
        return FormFactors.Desktop

    def __getattribute__(self, attr_name):
        attr = object.__getattribute__(self, attr_name);
        if attr_name.startswith("test_"):
            try:
                if self.form_factor() in attr.blacklist:
                    return self.skipWrapper
            except:
                pass
        return attr

    @property
    def main_window(self):
        return MainWindow(self.app)
