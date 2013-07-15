# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

from autopilot.matchers import Eventually
from testtools.matchers import Equals, NotEquals
from functools import wraps
import os.path

from unity8 import get_lib_path


import logging

logger = logging.getLogger(__name__)


def with_lightdm_mock(mock_type):
    """A simple decorator that sets up the LightDM mock for a single test."""
    def with_lightdm_mock_internal(fn):
        @wraps(fn)
        def wrapper(*args, **kwargs):
            logger.info("Setting up LightDM mock type '%s'", mock_type)
            lib_path = get_lib_path()
            new_ld_library_path = os.path.join(
                lib_path,
                "qml/mocks/LightDM/",
                mock_type
            )
            if not os.path.exists(new_ld_library_path):
                raise RuntimeError(
                    "LightDM mock '%s' does not exist." % mock_type
                )

            logger.info("New library path: %s", new_ld_library_path)
            args[0].patch_environment('LD_LIBRARY_PATH', new_ld_library_path)
            return fn(*args, **kwargs)
        return wrapper
    return with_lightdm_mock_internal


# TODO: Mixing classes like these are ikky. Remove them, and replace with
# something better!
class TestShellHelpers(object):
    """Helpers for testing the Shell"""

    def select_greeter_user(self, username):
        greeter = self.main_window.get_greeter()
        self.assertThat(greeter.created, Eventually(Equals(True)))
        self.assertThat(greeter.multiUser, Eventually(Equals(True)))

        login_loader = self.main_window.get_login_loader()
        self.assertThat(login_loader.progress, Eventually(Equals(1)))

        login_list = self.main_window.get_login_list()
        list_view = login_list.get_children_by_type("QQuickListView")[0]

        try_count = 0
        max_tries = 50  # just in case we go off rails
        while try_count < max_tries:
            users = list_view.get_children_by_type("QQuickItem")[0].get_children_by_type("QQuickItem")
            target_user = None
            for user in users:
                try:
                    user_label = user.get_children_by_type("Label")[0]
                    if user.opacity < 0.1:
                        continue  # off-screen item
                    if user_label.text == username:
                        target_user = user
                        break
                    elif target_user is None or user.y > target_user.y:
                        target_user = user
                except Exception:
                    pass
            if target_user is None:
                break
            user_label = target_user.get_children_by_type("Label")[0]
            self.touch.tap_object(user_label)
            self.assertThat(list_view.movingInternally, Eventually(Equals(False)))
            if user_label.text == username:
                return login_list.get_children_by_type("TextField")[0]
            try_count = try_count + 1
        self.fail()  # We didn't find it

    def unlock_greeter(self, retries=2):
        greeter = self.main_window.get_greeter()
        self.assertThat(greeter.created, Eventually(Equals(True)))

        if greeter.multiUser:
            password_field = self.select_greeter_user("No Password")
            self.assertThat(password_field.opacity, Eventually(Equals(1)))
            self.touch.tap_object(password_field)

        else:
            rect = greeter.globalRect
            start_x = rect[0] + rect[2] - 3
            start_y = int(rect[1] + rect[3] / 2)
            stop_x = int(rect[0] + rect[2] * 0.2)
            stop_y = start_y
            self.touch.drag(start_x, start_y, stop_x, stop_y)

        # Because the shell loads up lots of stuff, unlocking the greeter can
        # be a bit stuttery while scopes are still consuming all resources.
        # Give it another (max retries) chance
        try:
            self.assertThat(greeter.created, Eventually(Equals(False)))
        except:
            if retries > 0:
                logger.warning("Failed to unlock greeter. Retrying...")
                self.unlock_greeter(retries-1)
            else:
                logger.warning("Failed to unlock greeter. Giving up. Tests may fail...")


    def open_first_dash_home_app(self, retries=2):
        self.assertThat(lambda: self.main_window.get_dash_home_applications_grid(), Eventually(NotEquals(None)))
        app_grid = self.main_window.get_dash_home_applications_grid()
        # Wait for the grids to be expanded
        self.assertThat(app_grid.get_children()[0].totalContentHeight, Eventually(NotEquals(0)))
        self.assertThat(app_grid.get_children()[0].height, Eventually(Equals(app_grid.get_children()[0].totalContentHeight)))
        first_app = app_grid.get_children()[0].get_children()[0].get_children()[0].get_children()[0]
        self.touch.tap_object(first_app)
        bottombar = self.main_window.get_bottombar()

        # if we have huge amounts of pixels (e.g. Nexus10), but slow video (e.g. VM) it might take a little
        # until the dash is fully rendered after sliding away the greeter/lockscreen and the click might
        # go to the void for the first time because there's no real way to know what the display has
        # painted already. Give it another (max retries) chance.
        try:
            self.assertThat(lambda: getattr(bottombar, "applicationIsOnForeground"),
                            Eventually(Equals(True)))
        except:
            if retries > 0:
                logger.warning("Failed to launch app. Retrying...")
                self.open_first_dash_home_app(retries-1)
            else:
                logger.warning("Failed to launch app. Giving up. Tests may fail...")


    def show_hud(self, retries=2):
        self.open_first_dash_home_app()

        hud_show_button = self.main_window.get_hud_show_button()
        hud = self.main_window.get_hud()
        window = self.main_window.get_qml_view()
        start_x = int(window.x + window.width / 2)
        start_y = window.y + window.height - 3
        self.assertThat(hud_show_button.opacity, Eventually(Equals(0)))
        self.touch.press(start_x, start_y)
        self.touch._finger_move(start_x, start_y - self.grid_size)
        self.assertThat(hud_show_button.opacity, Eventually(Equals(0)))
        self.touch._finger_move(start_x, start_y - self.grid_size * 2)
        self.touch._finger_move(start_x, start_y - self.grid_size * 3)
        self.touch._finger_move(start_x, start_y - self.grid_size * 4)
        try:
            self.assertThat(hud_show_button.opacity, Eventually(Equals(1.0)))
        except:
            if retries > 0:
                logger.warning("Failed to get hud button to show. Retrying...")
                self.touch.release()
                self.show_hud(retries-1)
                return
            else:
                logger.warning("Failed to get hud button to show. Giving up. Tests may fail...")
        self.assertThat(hud_show_button.mouseOver, Eventually(Equals(False)))
        self.touch._finger_move(start_x, start_y - self.grid_size * 34)
        self.assertThat(hud_show_button.opacity, Eventually(Equals(1.0)))
        self.assertThat(hud_show_button.mouseOver, Eventually(Equals(True)))
        self.touch.release()
        self.assertThat(hud_show_button.opacity, Eventually(Equals(0)))
        self.assertThat(hud.shown, Eventually(Equals(True)))

    def close_hud_click(self):
        hud = self.main_window.get_hud()
        self.assertThat(hud.shown, Eventually(Equals(True)))
        rect = hud.globalRect
        x = int(rect[0] + rect[2] / 2)
        y = rect[1] + self.grid_size
        self.touch.tap(x, y)
        self.assertThat(hud.shown, Eventually(Equals(False)))

    def show_launcher(self):
        launcher = self.main_window.get_launcher()
        view = self.main_window.get_qml_view()
        start_x = view.x + 1
        start_y = view.y + view.height / 2
        stop_x = start_x + launcher.panelWidth + 1
        stop_y = start_y
        self.touch.drag(start_x, start_y, stop_x, stop_y)
        self.assertThat(launcher.shown, Eventually(Equals(True)))
