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

from unity8.tests import ShellTestCase, FormFactors
from unity8.tests.helpers import TestShellHelpers

from autopilot.input import Mouse, Touch, Pointer
from testtools.matchers import Equals, NotEquals, GreaterThan, MismatchError
from autopilot.matchers import Eventually
from autopilot.display import Display
from autopilot.platform import model

from gi.repository import GLib, Notify
import unittest
import time
import os
from os import path
import subprocess
import logging

logger = logging.getLogger(__name__)

class NotificationTestCase(ShellTestCase, TestShellHelpers):

    """Tests notifications"""

    def setUp(self):
        self.action_interactive_triggered = False
        self.action_accept_triggered = False
        self.action_send_message_triggered = False
        self.touch = Touch.create()
        super(NotificationTestCase, self).setUp("768x1280", "18")

        Notify.init("Autopilot Notification Tests")
        self.addCleanup(Notify.uninit)
        self.loop = GLib.MainLoop.new(None, False)

    def create_ephemeral(self, summary="", body="", icon=None, secondary_icon=None, urgency="NORMAL"):
        logger.info("Creating ephemeral notification with summary(%s), body(%s) and urgency(%r)", summary, body, urgency)
        if icon != None:
            logger.info("Using icon(%s)", icon)
        if secondary_icon != None:
            logger.info("Using secondary-icon(%s)", secondary_icon)

        n = Notify.Notification.new(summary, body, icon)
        if secondary_icon != None:
            n.set_hint('x-canonical-secondary-icon', GLib.Variant.new_string(secondary_icon))
        n.set_urgency(self._get_urgency(urgency))

        return n

    def create_interactive(self, summary="", body="", icon=None, secondary_icon=None, urgency="NORMAL", action_id="action_id", action_label="action_label", action_cb=None):
        logger.info("Creating interactive notification with summary(%s), body(%s) and urgency(%r)", summary, body, urgency)
        if icon != None:
            logger.info("Using icon(%s)", icon)
        if secondary_icon != None:
            logger.info("Using secondary-icon(%s)", secondary_icon)

        n = Notify.Notification.new(summary, body, icon)
        if secondary_icon != None:
            n.set_hint('x-canonical-secondary-icon', GLib.Variant.new_string(secondary_icon))
        n.set_hint('x-canonical-switch-to-application', GLib.Variant.new_string('true'));
        n.add_action(action_id, action_label, action_cb, None, None);
        n.connect('closed', self.close_cb)
        n.set_urgency(self._get_urgency(urgency))

        return n

    def create_snap_decision(self, summary="", body="", icon=None, secondary_icon=None, urgency="NORMAL", action_ids=None, action_labels=None, action_cbs=None):
        logger.info("Creating snap-decision notification with summary(%s), body(%s) and urgency(%r)", summary, body, urgency)
        if icon != None:
            logger.info("Using icon(%s)", icon)
        if secondary_icon != None:
            logger.info("Using secondary-icon(%s)", secondary_icon)

        size_ids = len(action_ids)
        size_labels = len(action_labels)
        size_cbs = len(action_cbs)
        if size_ids != size_labels and size_ids != size_cbs:
            logger.info("Array-sizes of action-ids (%d), action-labels (%d) and action-callbacks (%d) do not match!", size_ids, size_labels, size_cbs)
            return None

        n = Notify.Notification.new(summary, body, icon)
        if secondary_icon != None:
            n.set_hint('x-canonical-secondary-icon', GLib.Variant.new_string(secondary_icon))
        n.set_hint('x-canonical-snap-decisions', GLib.Variant.new_string('true'));
        for i in range(size_ids):
            n.add_action(action_ids[i], action_labels[i], action_cbs[i], None, None)
        n.connect('closed', self.close_cb)
        n.set_urgency(self._get_urgency(urgency))

        return n

    def create_confirmation(self, summary="", body="", icon=None, secondary_icon=None, urgency="NORMAL"):
        logger.info("Creating confirmation notification with summary(%s), body(%s) and urgency(%r)", summary, body, urgency)
        if icon != None:
            logger.info("Using icon(%s)", icon)
        if secondary_icon != None:
            logger.info("Using secondary-icon(%s)", secondary_icon)

        n = Notify.Notification.new(summary, body, icon)
        if secondary_icon != None:
            n.set_hint('x-canonical-secondary-icon', GLib.Variant.new_string(secondary_icon))
        n.set_hint('x-canonical-private-synchronous', GLib.Variant.new_string('true'));
        if summary == "" and body == "":
            n.set_hint('x-canonical-private-icon-only', GLib.Variant.new_string('true'));
        n.set_urgency(self._get_urgency(urgency))

        return n

    def _get_urgency(self, urgency):
        """Translates urgency string to enum."""
        _urgency_enums = {
            'LOW': Notify.Urgency.LOW,
            'NORMAL': Notify.Urgency.NORMAL,
            'CRITICAL': Notify.Urgency.CRITICAL,
        }

        return _urgency_enums.get(urgency.upper())

    def get_icon_path(self, icon_name):
        """Given an icons file name returns the full path (either system or
        source tree.

        Consider the graphics directory as root so for example (runnign tests
        from installed unity8-autopilot package):
        >>> self.get_icon_path('clock@18.png')
        /usr/share/unity8/graphics/clock@18.png

        >>> self.get_icon_path('applicationIcons/facebook@18.png')
        /usr/share/unity8/graphics/applicationIcons/facebook@18.png

        """
        if os.path.abspath(__file__).startswith('/usr/'):
            return '/usr/share/unity8/graphics/' + icon_name
        else:
            return os.path.abspath(os.getcwd() + "/../../graphics/" + icon_name)

    def get_notifications_list(self):
        main_view = self.main_window.get_qml_view()
        return main_view.select_single("QQuickListView", objectName='notificationList')

    def assert_notification(self, notification, summary=None, body=None, icon=True, secondary_icon=False, opacity=None):
        if summary != None:
            self.assertThat(notification.summary, Equals(summary))

        if body != None:
            self.assertThat(notification.body, Equals(body))

        if icon:
            self.assertThat(notification.iconSource, NotEquals(""))
        else:
            self.assertThat(notification.iconSource, Equals(""))

        if secondary_icon:
            self.assertThat(notification.secondaryIconSource, NotEquals(""))
        else:
            self.assertThat(notification.secondaryIconSource, Equals(""))

        if opacity != None:
            self.assertThat(notification.opacity, Eventually(Equals(opacity)))

    def action_interactive_cb (self, notification, action, data):
        if action == "action_id":
            logger.info("--- Triggering action ---")
            self.action_interactive_triggered = True
        else:
            logger.info("--- That should not have happened (action_id)! ---")
            self.action_interactive_triggered = False

    def action_sd_decline1_cb (self, notification, action, data):
        if action == "action_decline_1":
            print "Decline"
        else:
            print "That should not have happened (action_decline_1)!"

    def action_sd_decline2_cb (self, notification, action, data):
        if action == "action_decline_2":
            print "\"Can't talk now, what's up?\""
        else:
            print "That should not have happened (action_decline_2)!"

    def action_sd_decline3_cb (self, notification, action, data):
        if action == "action_decline_3":
            print "\"I call you back.\""
        else:
            print "That should not have happened (action_decline_3)!"

    def action_sd_decline4_cb (self, notification, action, data):
        if action == "action_decline_4":
            print "Send custom message..."
            self.action_send_message_triggered = True
        else:
            print "That should not have happened (action_decline_4)!"
            self.action_send_message_triggered = False

    def action_sd_accept_cb (self, notification, action, data):
        if action == "action_accept":
            print "Accepting call"
            self.action_accept_triggered = True
        else:
            print "That should not have happened (action_accept)!"
            self.action_accept_triggered = False

    def close_cb(self, notification):
        self.loop.quit()

class TestNotifications(NotificationTestCase):
    def test_icon_summary_body(self):
        """Notification must display the expected summary and body text."""
        notify_list = self.get_notifications_list()
        self.unlock_greeter()

        summary = "Icon-Summary-Body"
        body = "Hey pal, what's up with the party next weekend? Will you join me and Anna?"
        icon_path = self.get_icon_path('avatars/anna_olsson@12.png')
        hint_icon = self.get_icon_path('applicationIcons/phone-app@18.png')

        notification = self.create_ephemeral(summary, body, icon_path, hint_icon)
        notification.show()

        get_notification = lambda: notify_list.select_single('Notification')
        self.assertThat(get_notification, Eventually(NotEquals(None)))
        notification = get_notification()
        self.assert_notification(notification, summary, body, True, True, 1.0)

    #def test_interactive(self):
    #    """Interactive notification must allow clicking on it."""
    #    notify_list = self.get_notifications_list()
    #    self.unlock_greeter()
    #
    #    summary = "Interactive notification"
    #    body = "Click this notification to trigger the attached action."
    #    icon_path = self.get_icon_path('avatars/anna_olsson@12.png')
    #    hint_icon = self.get_icon_path('applicationIcons/phone-app@18.png')
    #
    #    notification = self.create_interactive(summary,
    #                                           body,
    #                                           icon_path,
    #                                           hint_icon,
    #                                           "NORMAL",
    #                                           "action_id",
    #                                           "dummy",
    #                                           self.action_interactive_cb)
    #    notification.show()
    #    self.loop.run()
    #
    #    get_notification = lambda: notify_list.select_single('Notification')
    #    self.assertThat(get_notification, Eventually(NotEquals(None)))
    #    notification = get_notification()
    #    self.assert_notification(notification, None, None, True, True, 1.0)
    #    self.touch.tap_object(notification.select_single(objectName="interactiveArea"))
    #    self.assertThat(self.action_interactive_triggered, Equals(True))

    #def test_sd_incoming_call(self):
    #    """Snap-decision simulating incoming call."""
    #    notify_list = self.get_notifications_list()
    #    self.unlock_greeter()
    #
    #    summary = "Incoming call"
    #    body = "Frank Zappa\n+44 (0)7736 027340"
    #    icon_path = self.get_icon_path('avatars/anna_olsson@12.png')
    #    hint_icon = self.get_icon_path('applicationIcons/phone-app@18.png')
    #
    #    action_ids = ['action_accept', 'action_decline_1', 'action_decline_2', 'action_decline_3', 'action_decline_4']
    #    action_labels = ['Accept', 'Decline', '"Can\'t talk now, what\'s up?"', '"I call you back."', 'Send custom message...']
    #    action_cbs = [self.action_sd_accept_cb, self.action_sd_decline1_cb, self.action_sd_decline2_cb, self.action_sd_decline3_cb, self.action_sd_decline4_cb]
    #    notification = self.create_snap_decision(summary, body, icon_path, hint_icon, "NORMAL", action_ids, action_labels, action_cbs)
    #    notification.show()
    #    self.loop.run()
    #
    #    get_notification = lambda: notify_list.select_single('Notification')
    #    self.assertThat(get_notification, Eventually(NotEquals(None)))
    #    notification = get_notification()
    #    self.assert_notification(notification, None, None, True, True, 1.0)
    #    self.touch.tap_object(notification.select_single(objectName="button1"))
    #    self.assertThat(notification.select_single(objectName="buttonRow").expanded, Eventually(Equals(True)))
    #    self.touch.tap_object(notification.select_single(objectName="button4"))
    #    self.assertThat(self.action_send_message_triggered, Equals(True))

    def test_icon_summary(self):
        notify_list = self.get_notifications_list()
        self.unlock_greeter()

        summary = "Upload of image completed"
        hint_icon = self.get_icon_path('applicationIcons/facebook@18.png')

        notification = self.create_ephemeral(summary, None, None, hint_icon)
        notification.show()

        get_notification = lambda: notify_list.select_single('Notification')
        self.assertThat(get_notification, Eventually(NotEquals(None)))
        notification = get_notification()
        self.assert_notification(notification, summary, None, False, True, 1.0)

    def test_urgency_order(self):
        notify_list = self.get_notifications_list()
        self.unlock_greeter()

        summary_low = 'Low Urgency'
        body_low = "No, I'd rather see paint dry, pal *yawn*"
        icon_path_low = self.get_icon_path('avatars/amanda@12.png')
        summary_normal = 'Normal Urgency'
        body_normal = "Hey pal, what's up with the party next weekend? Will you join me and Anna?"
        icon_path_normal = self.get_icon_path('avatars/funky@12.png')
        summary_critical = 'Critical Urgency'
        body_critical = 'Dude, this is so urgent you have no idea :)'
        icon_path_critical = self.get_icon_path('avatars/anna_olsson@12.png')

        notification_normal = self.create_ephemeral(summary_normal, body_normal, icon_path_normal, None, "NORMAL")
        notification_normal.show()
        notification_low = self.create_ephemeral(summary_low, body_low, icon_path_low, None, "LOW")
        notification_low.show()
        notification_critical = self.create_ephemeral(summary_critical, body_critical, icon_path_critical, None, "CRITICAL")
        notification_critical.show()

        time.sleep(4)
        get_notification = lambda: notify_list.select_single('Notification')
        self.assertThat(get_notification, Eventually(NotEquals(None)))
        notification = get_notification()
        self.assert_notification(notification, summary_critical, body_critical, True, False, 1.0)

        time.sleep(4)
        notification = get_notification()
        self.assert_notification(notification, summary_normal, body_normal, True, False, 1.0)

        time.sleep(4)
        notification = get_notification()
        self.assert_notification(notification, summary_low, body_low, True, False, 1.0)

    def test_summary_body(self):
        notify_list = self.get_notifications_list()
        self.unlock_greeter()

        summary = 'Summary-Body'
        body = 'This is a superfluous notification'

        notification = self.create_ephemeral(summary, body)
        notification.show()

        get_notification = lambda: notify_list.select_single('Notification')
        self.assertThat(get_notification, Eventually(NotEquals(None)))
        notification = get_notification()
        self.assert_notification(notification, summary, body, False, False, 1.0)

    def test_summary_only(self):
        notify_list = self.get_notifications_list()
        self.unlock_greeter()

        summary = 'Summary-Only'

        notification = self.create_ephemeral(summary)
        notification.show()

        get_notification = lambda: notify_list.select_single('Notification')
        self.assertThat(get_notification, Eventually(NotEquals(None)))
        notification = get_notification()
        self.assert_notification(notification, summary, '', False, False, 1.0)

    def test_update_notification(self):
        notify_list = self.get_notifications_list()
        self.unlock_greeter()

        summary = 'Inital notification (1. notification)'
        body = 'This is the original content of this notification-bubble.'
        icon_path = self.get_icon_path('avatars/funky@12.png')
        notification = self.create_ephemeral(summary, body, icon_path)
        notification.show()
        get_notification = lambda: notify_list.select_single('Notification')
        self.assertThat(get_notification, Eventually(NotEquals(None)))
        self.assert_notification(get_notification(), summary, body, True, False, 1.0)

        time.sleep(3)
        summary = 'Updated notification (1. notification)'
        body = 'Here the same bubble with new title- and body-text, even the icon can be changed on the update.'
        icon_path = self.get_icon_path('avatars/amanda@12.png')
        notification.update(summary, body, icon_path)
        notification.show ();
        self.assertThat(get_notification, Eventually(NotEquals(None)))
        self.assert_notification(get_notification(), summary, body)

        time.sleep(6)
        summary = 'Initial layout (2. notification)'
        body = 'This bubble uses the icon-title-body layout with a secondary icon.'
        icon_path = self.get_icon_path('avatars/anna_olsson@12.png')
        hint_icon = self.get_icon_path('applicationIcons/phone-app@18.png')
        notification = self.create_ephemeral(summary, body, icon_path)
        notification.set_hint('x-canonical-secondary-icon', GLib.Variant.new_string(hint_icon))
        notification.show ();
        self.assertThat(get_notification, Eventually(NotEquals(None)))
        self.assert_notification(get_notification(), summary, body, True, True, 1.0)

        time.sleep(3)
        notification.clear_hints()
        summary = 'Updated layout (2. notification)'
        body = 'After the update we now have a bubble using the title-body layout.'
        notification.update(summary, body, None)
        notification.show()
        self.assertThat(get_notification, Eventually(NotEquals(None)))
        self.assert_notification(get_notification(), summary, body, False)

    def test_append_hint(self):
        notify_list = self.get_notifications_list()
        self.unlock_greeter()

        summary = 'Cole Raby'
        body = 'Hey Bro Coly!'
        icon_path = self.get_icon_path('avatars/amanda@12.png')
        body_sum = body
        notification = self.create_ephemeral(summary, body, icon_path)
        notification.set_hint('x-canonical-append', GLib.Variant.new_string('true'));
        notification.show()
        get_notification = lambda: notify_list.select_single('Notification')
        self.assertThat(get_notification, Eventually(NotEquals(None)))
        notification = get_notification()
        self.assert_notification(notification, summary, body_sum, True, False, 1.0)

        bodies = ['What\'s up dude?',
                  'Did you watch the air-race in Oshkosh last week?',
                  'Phil owned the place like no one before him!',
                  'Did really everything in the race work according to regulations?',
                  'Somehow I think to remember Burt Williams did cut corners and was not punished for this.',
                  'Hopefully the referees will watch the videos of the race.',
                  'Burt could get fined with US$ 50000 for that rule-violation :)']

        for new_body in bodies:
            time.sleep(1)
            body = new_body
            body_sum += '\n' + body
            notification = self.create_ephemeral(summary, body, icon_path)
            notification.set_hint('x-canonical-append', GLib.Variant.new_string('true'));
            notification.show()
            get_notification = lambda: notify_list.select_single('Notification')
            self.assertThat(get_notification, Eventually(NotEquals(None)))
            notification = get_notification()
            self.assert_notification(notification, summary, body_sum, True, False, 1.0)
