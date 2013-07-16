# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.


# This file contains general purpose test cases for Unity.
# Each test written in this file will be executed for a variety of
# configurations, such as Phone, Tablet or Desktop form factors.
#
# Sometimes there is the need to disable a certain test for a particular
# configuration. To do so, add this in a new line directly below your test:
#
#    test_testname.blacklist = (FormFactors.Tablet, FormFactors.Desktop,)
#
# Available form factors are:
# FormFactors.Phone
# FormFactors.Tablet
# FormFactors.Desktop


"""Tests for the Shell"""

from __future__ import absolute_import

from collections import namedtuple

from unity8.shell.tests import Unity8TestCase, _get_device_emulation_scenarios

from autopilot.input import Touch
from testtools.matchers import Equals, MismatchError
from autopilot.matchers import Eventually
from autopilot.display import Display
from autopilot.platform import model


SwipeCoords = namedtuple('SwipeCoords', 'start_x end_x start_y end_y')


class TestHud(Unity8TestCase):

    """Tests the Shell HUD"""

    scenarios = _get_device_emulation_scenarios()

    def test_show_hud_button_appears(self):
        """Swiping up while an app is active must show the 'show hud' button."""
        self.launch_unity()
        self.main_window.get_greeter().unlock()
        window = self.main_window.get_qml_view()
        hud_show_button = self.main_window.get_hud_show_button()
        hud = self.main_window.get_hud()

        self._launch_application_from_app_screen()

        swipe_coords = self._get_hud_button_swipe_coords(window, hud_show_button)
        self.touch.press(swipe_coords.start_x, swipe_coords.start_y)
        self.addCleanup(self.touch.release)
        self.touch._finger_move(swipe_coords.end_x, swipe_coords.end_y)
        self.assertThat(hud_show_button.opacity, Eventually(Equals(1.0)))

    def test_show_hud_appears(self):
        """Releasing the touch on the 'show hud' button must display the hud."""
        self.launch_unity()
        self.main_window.get_greeter().unlock()
        window = self.main_window.get_qml_view()
        hud_show_button = self.main_window.get_hud_show_button()
        hud = self.main_window.get_hud()

        self._launch_application_from_app_screen()

        swipe_coords = self._get_hud_button_swipe_coords(window, hud_show_button)
        self.touch.press(swipe_coords.start_x, swipe_coords.start_y)
        self.addCleanup(self._maybe_release_finger)
        self.touch._finger_move(swipe_coords.end_x, swipe_coords.end_y)

        self.assertThat(hud.shown, Eventually(Equals(False)))
        self.assertThat(hud_show_button.opacity, Eventually(Equals(1.0)))
        self.touch.release()
        self.assertThat(hud.shown, Eventually(Equals(True)))

    # def test_show_hud_button_dont_open(self):
    #     self.launch_unity()
    #     hud_show_button = self.main_window.get_hud_show_button()
    #     hud = self.main_window.get_hud()
    #     greeter = self.main_window.get_greeter()
    #     greeter.unlock()

    #     self.unlock_greeter()
    #     self.open_first_dash_home_app()
    #     hud_show_button = self.main_window.get_hud_show_button()
    #     hud = self.main_window.get_hud()
    #     window = self.main_window.get_qml_view()
    #     start_x = int(window.x + window.width / 2)
    #     start_y = window.y + window.height - 2
    #     self.assertThat(hud_show_button.opacity, Eventually(Equals(0)))
    #     self.touch.press(start_x, start_y)
    #     self.touch._finger_move(start_x, start_y - self.grid_size)
    #     self.assertThat(hud_show_button.opacity, Eventually(Equals(0)))
    #     self.touch._finger_move(start_x, start_y - self.grid_size * 2)
    #     self.touch._finger_move(start_x, start_y - self.grid_size * 3)
    #     self.touch._finger_move(start_x, start_y - self.grid_size * 4)
    #     self.assertThat(hud_show_button.opacity, Eventually(Equals(1.0)))
    #     self.assertThat(hud_show_button.mouseOver, Eventually(Equals(False)))
    #     self.touch._finger_move(start_x, start_y - self.grid_size * 34)
    #     self.assertThat(hud_show_button.opacity, Eventually(Equals(1.0)))
    #     self.assertThat(hud_show_button.mouseOver, Eventually(Equals(True)))
    #     self.touch._finger_move(start_x, start_y - self.grid_size)
    #     self.assertThat(hud_show_button.opacity, Eventually(Equals(1.0)))
    #     self.assertThat(hud_show_button.mouseOver, Eventually(Equals(False)))
    #     self.touch.release()
    #     self.assertThat(hud_show_button.opacity, Eventually(Equals(0)))
    #     self.assertThat(hud.shown, Eventually(Equals(False)))

    def test_hide_hud_click(self):
        """Tapping the close button of the Hud must dismiss it."""
        self.launch_unity()
        self.main_window.get_greeter().unlock()
        hud = self.main_window.get_hud()
        hud.show()

        self._launch_application_from_app_screen()

        rect = hud.globalRect
        x = int(rect[0] + rect[2] / 2)
        y = rect[1] + self.grid_size

        self.touch.tap(x, y)
        self.assertThat(hud.shown, Eventually(Equals(False)))

    # def test_hide_hud_click_outside_handle(self):
    #     hud = self.main_window.get_hud()
    #     self.unlock_greeter()
    #     self.show_hud()
    #     rect = hud.globalRect
    #     x = int(rect[0] + rect[2] / 2)
    #     y = rect[1] + hud.handleHeight + 1
    #     self.touch.tap(x, y)
    #     self.assertRaises(MismatchError, lambda: self.assertThat(hud.shown, Eventually(Equals(False), timeout=3)))

    # def test_hide_hud_dragging(self):
    #     hud = self.main_window.get_hud()
    #     self.unlock_greeter()
    #     self.show_hud()
    #     rect = hud.globalRect
    #     start_x = rect[0] + (rect[2] - rect[0]) / 2
    #     start_y = rect[1] + 1
    #     stop_x = start_x
    #     stop_y = start_y + (rect[3] - rect[1]) / 2
    #     self.touch.drag(start_x, start_y, stop_x, stop_y)
    #     self.assertThat(hud.shown, Eventually(Equals(False)))

    def test_launcher_hides_hud(self):
        """Opening the Launcher while the Hud is active must close the Hud."""
        self.launch_unity()
        self.main_window.get_greeter().unlock()
        hud = self.main_window.get_hud()
        launcher = self.main_window.get_launcher()

        self._launch_application_from_app_screen()

        hud.show()
        launcher.show()

        self.assertThat(hud.shown, Eventually(Equals(False)))

    def _launch_application_from_app_screen(self):
        """Launches the camera app using the Dash UI.

        This is becuase when testing on the desktop running
        self.launch_application() will launch the application on the desktop
        itself and not within the Unity8 UI.

        """
        dash = self.main_window.get_dash()
        icon = dash.get_application_icon('Camera')
        self.touch.tap_object(icon)

        # Ensure application is open
        bottombar = self.main_window.get_bottombar()
        self.assertThat(bottombar.applicationIsOnForeground, Eventually(Equals(True)))

    # Because some tests are manually manipulating the finger, we want to
    # cleanup if the test fails, but we don't want to fail with an exception if
    # we don't.
    def _maybe_release_finger(self):
        """Only release the finger if it is in fact down."""
        if self.touch._touch_finger is not None:
            self.touch.release()

    def _get_hud_button_swipe_coords(self, main_view, hud_show_button):
        start_x = int(main_view.x + (main_view.width / 2))
        end_x = start_x
        start_y = main_view.y + (main_view.height -3)
        end_y = int(hud_show_button.y)

        return SwipeCoords(start_x, end_x, start_y, end_y)
