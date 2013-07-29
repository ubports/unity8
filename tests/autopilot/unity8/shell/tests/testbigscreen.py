# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Add tests here if you want to ensure everything is aligned correctly on huge screens. Because this test does not fit on most screens, you should not use input devices here or your tests are likely to fail"""

from testtools.matchers import Equals
from autopilot.matchers import Eventually

from unity8.tests import ShellTestCase

class TestBig(ShellTestCase):
    def setUp(self):
        super(TestBig, self).setUp("2560x1600", "20")
        self.assertThat(self.main_window.get_qml_view().visible, Eventually(Equals(True)))

    def tearDown(self):
        super(TestBig, self).tearDown()

    def test_hud_not_shown_greeter(self):
        hud_showable = self.main_window.get_hud_showable()
        self.assertThat(hud_showable.y, Eventually(Equals(1600)))
