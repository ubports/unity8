# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity8 Autopilot Test Suite
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

from unity8.shell.emulators import Unity8EmulatorBase
from autopilot.input import Touch


class Greeter(Unity8EmulatorBase):

    """An emulator that understands the greeter screen."""

    def unlock(self):
        """Swipe the greeter screen away."""
        self.created.wait_for(True)
        touch = Touch.create()

        # TODO: Is this ever called? Find out, and maybe remove this branch:
        if self.multiUser:
            # this is borked!
            password_field = self.select_greeter_user("No Password")
            password_field.opacity.wait_for(1)
            touch.tap_object(password_field)

        else:
            rect = self.globalRect
            start_x = rect[0] + rect[2] - 3
            start_y = int(rect[1] + rect[3] / 2)
            stop_x = int(rect[0] + rect[2] * 0.2)
            stop_y = start_y
            touch.drag(start_x, start_y, stop_x, stop_y)

        self.created.wait_for(False)

    #TODO: This was moved here from helpers.TestShellHelpers
    # Needs a cleanup (used in borked above).
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
