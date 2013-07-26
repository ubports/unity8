#!/usr/bin/env python

import argparse
from gi.repository import GLib, Notify
import signal


def action_callback(notification, action_id, data):
    print action_id


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
        key, value = hint.split(',')
        notification.set_hint_string(key, value)
    notification.set_hint_string("x-canonical-switch-to-application", "true")

    for action in args.action:
        action_id, action_label = action.split(',')
        notification.add_action(
            action_id,
            action_label,
            action_callback,
            None,
            None
        )

    def signal_handler(signam, frame):
        loop.quit()

    signal.signal(signal.SIGINT, signal_handler)

    loop = GLib.MainLoop.new(None, False)
    notification.connect('closed', quit_callback)
    notification.show()
    loop.run()
