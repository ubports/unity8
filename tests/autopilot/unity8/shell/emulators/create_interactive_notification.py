#!/usr/bin/env python3

# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity Autopilot Test Suite
# Copyright (C) 2012, 2013, 2014, 2015 Canonical
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

import argparse
from gi.repository import GLib, Notify
import signal


def action_callback(notification, action_id, data):
    print(action_id)


def quit_callback(notification):
    loop.quit()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Create an interactive notification'
    )

    parser.add_argument(
        '--summary',
        help='summary text of the notification',
        default='Summary'
    )
    parser.add_argument(
        '--body',
        help='body text of the notification',
        default='Body'
    )
    parser.add_argument(
        '--icon',
        help='path to the icon to display',
        default=None
    )
    parser.add_argument(
        '--action',
        help='id and label for the callback in the format: id,label',
        action='append',
        default=[]
    )
    parser.add_argument(
        '--urgency',
        help='LOW, NORMAL, CRITICAL',
        choices=['LOW', 'NORMAL', 'CRITICAL'],
        default='NORMAL'
    )
    parser.add_argument(
        '--hints',
        help='list of comma sep options',
        action='append',
        default=[]
    )

    args = parser.parse_args()

    Notify.init('Interactive Notifications')

    notification = Notify.Notification.new(args.summary, args.body, args.icon)

    for hint in args.hints:
        key, value = hint.split(',', 1)
        notification.set_hint_string(key, value)

    for action in args.action:
        action_id, action_label = action.split(',', 1)
        notification.add_action(
            action_id,
            action_label,
            action_callback,
            None
        )

    def signal_handler(signam, frame):
        loop.quit()

    signal.signal(signal.SIGINT, signal_handler)

    loop = GLib.MainLoop.new(None, False)
    notification.connect('closed', quit_callback)
    notification.show()
    loop.run()
