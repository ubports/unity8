# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""unity8 autopilot tests."""

import os.path
import sysconfig

from autopilot.testcase import AutopilotTestCase
from autopilot.matchers import Eventually
from autopilot.platform import model
from testtools.matchers import Equals

from unity8.shell.emulators.main_window import MainWindow

class FormFactors(object):
    Phone, Tablet, Desktop = range(3)

class ShellTestCase(AutopilotTestCase):

    """A common test case class that provides several useful methods for shell tests."""

    libdir = "/usr/lib/{0}/unity8".format(sysconfig.get_config_var('MULTIARCH'))
    lightdm_mock = "full"

    def setUp(self, geometry, grid_size):
        super(ShellTestCase, self).setUp()
        # Lets assume we are installed system wide if this file is somewhere in /usr
        if grid_size != "0":
            os.environ['GRID_UNIT_PX'] = grid_size
            self.grid_size = int(grid_size)
        else:
            self.grid_size = int(os.environ['GRID_UNIT_PX'])
        if os.path.realpath(__file__).startswith("/usr/"):
            self.launch_test_installed(geometry)
        else:
            self.launch_test_local(geometry)

    def launch_test_local(self, geometry):
        os.environ['LD_LIBRARY_PATH'] = "../../builddir/tests/mocks/libusermetrics:../../builddir/tests/mocks/LightDM" + self.lightdm_mock
        os.environ['QML2_IMPORT_PATH'] = "../../builddir/tests/mocks"
        if geometry != "0x0":
            self.app = self.launch_test_application(
                "../../builddir/unity8", "-geometry", geometry, "-frameless", app_type='qt')
        else:
            self.app = self.launch_test_application(
                "../../builddir/unity8", "-fullscreen", app_type='qt')

    def launch_test_installed(self, geometry):
        os.environ['LD_LIBRARY_PATH'] = "{0}/qml/mocks/libusermetrics:{0}/qml/mocks/LightDM/{1}".format(self.libdir, self.lightdm_mock)
        os.environ['QML2_IMPORT_PATH'] = "{0}/qml/mocks".format(self.libdir)
        if model() == 'Desktop' and geometry != "0x0":
            self.app = self.launch_test_application(
               "unity8", "-geometry", geometry, "-frameless", app_type='qt')
        else:
            self.app = self.launch_test_application(
               "unity8", "-fullscreen", app_type='qt')

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
