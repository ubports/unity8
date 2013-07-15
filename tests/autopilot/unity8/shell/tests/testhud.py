# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.


"""Tests for the Shell"""

from __future__ import absolute_import

from unity8.shell.tests import Unity8TestCase

from autopilot.input import Touch
from testtools.matchers import Equals, MismatchError
from autopilot.matchers import Eventually
from autopilot.display import Display


class TestHud(Unity8TestCase):

    """Tests the Shell HUD."""

    # Scenarios:
    # Fill in the scenarios to run the whole test suite with multiple configurations.
    # Use app_width, app_height and grid_unit_px to set the apps geometry.
    # Set app_width and app_height to 0 to use fullscreen.
    # Set grid_unit_px to 0 to use the current system environment.

#     if model() == 'Desktop':
#         scenarios = [
#             ('Nexus 4', dict(app_width=768, app_height=1280, grid_unit_px=18, lightdm_mock="single")),
#             ('Nexus 10', dict(app_width=2560, app_height=1600, grid_unit_px=20, lightdm_mock="full")),
# # TODO: don't run fullscreen tests just yet as the VM is performing too badly for that. Enable this once
# # Autopilot tests are running on bear metal.
# #            ('Fullscreen', dict(app_width=0, app_height=0, grid_unit_px=10, lightdm_mock="full")),
#         ]
#     else:
#         scenarios = [
#             ('Fullscreen', dict(app_width=0, app_height=0, grid_unit_px=0, lightdm_mock="single")),
#         ]

    def setUp(self):
        self.touch = Touch.create()

        sg = Display().create()
        divisor = 1
        while (sg.get_screen_width() < self.app_width / divisor or sg.get_screen_height() < self.app_height / divisor):
            divisor = divisor * 2
        super(TestHud, self).setUp("%sx%s" % (self.app_width / divisor, self.app_height / divisor), "%s" % (self.grid_unit_px / divisor))

        dash = self.main_window.get_dash()
        self.assertThat(dash.showScopeOnLoaded, Eventually(Equals(""), timeout=30))

    def test_show_hud(self):
        hud = self.main_window.get_hud()
        self.unlock_greeter()
        self.show_hud()
        self.assertThat(hud.shown, Eventually(Equals(True)))

    def test_show_hud_button_dont_open(self):
        self.unlock_greeter()
        self.open_first_dash_home_app()
        hud_show_button = self.main_window.get_hud_show_button()
        hud = self.main_window.get_hud()
        window = self.main_window.get_qml_view()
        start_x = int(window.x + window.width / 2)
        start_y = window.y + window.height - 2
        self.assertThat(hud_show_button.opacity, Eventually(Equals(0)))
        self.touch.press(start_x, start_y)
        self.touch._finger_move(start_x, start_y - self.grid_size)
        self.assertThat(hud_show_button.opacity, Eventually(Equals(0)))
        self.touch._finger_move(start_x, start_y - self.grid_size * 2)
        self.touch._finger_move(start_x, start_y - self.grid_size * 3)
        self.touch._finger_move(start_x, start_y - self.grid_size * 4)
        self.assertThat(hud_show_button.opacity, Eventually(Equals(1.0)))
        self.assertThat(hud_show_button.mouseOver, Eventually(Equals(False)))
        self.touch._finger_move(start_x, start_y - self.grid_size * 34)
        self.assertThat(hud_show_button.opacity, Eventually(Equals(1.0)))
        self.assertThat(hud_show_button.mouseOver, Eventually(Equals(True)))
        self.touch._finger_move(start_x, start_y - self.grid_size)
        self.assertThat(hud_show_button.opacity, Eventually(Equals(1.0)))
        self.assertThat(hud_show_button.mouseOver, Eventually(Equals(False)))
        self.touch.release()
        self.assertThat(hud_show_button.opacity, Eventually(Equals(0)))
        self.assertThat(hud.shown, Eventually(Equals(False)))

    def test_hide_hud_click(self):
        hud = self.main_window.get_hud()
        self.unlock_greeter()
        self.show_hud()
        self.close_hud_click()
        self.assertThat(hud.shown, Eventually(Equals(False)))

    def test_hide_hud_click_outside_handle(self):
        hud = self.main_window.get_hud()
        self.unlock_greeter()
        self.show_hud()
        rect = hud.globalRect
        x = int(rect[0] + rect[2] / 2)
        y = rect[1] + hud.handleHeight + 1
        self.touch.tap(x, y)
        self.assertRaises(MismatchError, lambda: self.assertThat(hud.shown, Eventually(Equals(False), timeout=3)))

    def test_hide_hud_dragging(self):
        hud = self.main_window.get_hud()
        self.unlock_greeter()
        self.show_hud()
        rect = hud.globalRect
        start_x = rect[0] + (rect[2] - rect[0]) / 2
        start_y = rect[1] + 1
        stop_x = start_x
        stop_y = start_y + (rect[3] - rect[1]) / 2
        self.touch.drag(start_x, start_y, stop_x, stop_y)
        self.assertThat(hud.shown, Eventually(Equals(False)))

    def test_hide_hud_launcher(self):
        hud = self.main_window.get_hud()
        self.unlock_greeter()
        self.show_hud()
        self.show_launcher()
        self.assertThat(hud.shown, Eventually(Equals(False)))
