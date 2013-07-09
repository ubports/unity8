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
        self.touch = Touch.create()
        super(NotificationTestCase, self).setUp("768x1280", "18")

        Notify.init("Autopilot Notification Tests")
        self.addCleanup(Notify.uninit)

    def create_notification(self, title="", body="", asset=None, urgency='NORMAL'):
        logger.info("Creating notification with title(%s) body(%s) and urgency(%r)", title, body, urgency)
        n = Notify.Notification.new(title, body, asset)
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

    def action_interactive_cb (self, notification, action):
        if action == "action_id":
            logger.info("--- Triggering action ---")
            self.action_interactive_triggered = True
        else:
            logger.info("--- That should not have happened (action_id)! ---")
            self.action_interactive_triggered = False

    def action_sd_decline1_cb (self, notification, action):
        if action == "action_decline_1":
            print "Decline"
        else:
            print "That should not have happened (action_decline_1)!"

    def action_sd_decline2_cb (self, notification, action):
        if action == "action_decline_2":
            print "\"Can't talk now, what's up?\""
        else:
            print "That should not have happened (action_decline_2)!"

    def action_sd_decline3_cb (self, notification, action):
        if action == "action_decline_3":
            print "\"I call you back.\""
        else:
            print "That should not have happened (action_decline_3)!"

    def action_sd_decline4_cb (self, notification, action):
        if action == "action_decline_4":
            print "Send custom message..."
        else:
            print "That should not have happened (action_decline_4)!"

    def action_sd_accept_cb (self, notification, action):
        if action == "action_accept":
            print "Accepting call"
        else:
            print "That should not have happened (action_accept)!"

class TestNotifications(NotificationTestCase):
    def test_icon_summary_body(self):
        """Notification must display the expected summary and body text."""
        notify_list = self.get_notifications_list()
        self.unlock_greeter()

        summary = "Icon-Summary-Body"
        body = "Hey pal, what's up with the party next weekend? Will you join me and Anna?"
        icon_path = self.get_icon_path('avatars/anna_olsson@12.png')
        hint_icon = self.get_icon_path('applicationIcons/phone-app@18.png')

        notification = self.create_notification(summary, body, icon_path)
        notification.set_hint('x-canonical-secondary-icon', GLib.Variant.new_string(hint_icon))
        notification.show()

        get_notification = lambda: notify_list.select_single('Notification')
        self.assertThat(get_notification, Eventually(NotEquals(None)))
        notification = get_notification()
        self.assertThat(notification.summary, Equals(summary))
        self.assertThat(notification.body, Equals(body))
        self.assertThat(notification.opacity, Eventually(Equals(1.0)))

    def test_interactive(self):
        """Interactive notification must allow clicking on it."""
        notify_list = self.get_notifications_list()
        self.unlock_greeter()

        summary = "Interactive notification"
        body = "Click this notification to trigger the attached action."
        icon_path = self.get_icon_path('avatars/anna_olsson@12.png')
        hint_icon = self.get_icon_path('applicationIcons/phone-app@18.png')

        notification = self.create_notification(summary, body, icon_path)
        notification.set_hint('x-canonical-secondary-icon', GLib.Variant.new_string(hint_icon))
        notification.set_hint('x-canonical-switch-to-application', GLib.Variant.new_string('true'));
        notification.add_action('action_id', 'dummy', self.action_interactive_cb, None, None);
        notification.show()

        get_notification = lambda: notify_list.select_single('Notification')
        self.assertThat(get_notification, Eventually(NotEquals(None)))
        notification = get_notification()
        self.assertThat(notification.opacity, Eventually(Equals(1.0)))
        self.touch.tap_object(notification.select_single(objectName="interactiveArea"))
        #self.assertThat (self.action_interactive_triggered, Equals(True))

    def test_sd_incoming_call(self):
        """Snap-decision simulating incoming call."""
        notify_list = self.get_notifications_list()
        self.unlock_greeter()

        summary = "Incoming call"
        body = "Frank Zappa\n+44 (0)7736 027340"
        icon_path = self.get_icon_path('avatars/anna_olsson@12.png')
        hint_icon = self.get_icon_path('applicationIcons/phone-app@18.png')

        notification = self.create_notification(summary, body, icon_path)
        notification.add_action ('action_accept', 'Accept', self.action_sd_accept_cb, None, None);
        notification.add_action ('action_decline_1', 'Decline', self.action_sd_decline1_cb, None, None);
        notification.add_action ('action_decline_2', "\"Can't talk now, what's up?\"", self.action_sd_decline2_cb, None, None);
        notification.add_action ('action_decline_3', '\"I call you back.\"', self.action_sd_decline3_cb, None, None);
        notification.add_action ('action_decline_4', 'Send custom message...', self.action_sd_decline4_cb, None, None);
        notification.set_hint('x-canonical-snap-decisions', GLib.Variant.new_string('true'));
        notification.set_hint('x-canonical-secondary-icon', GLib.Variant.new_string(hint_icon))
        notification.show()

        get_notification = lambda: notify_list.select_single('Notification')
        self.assertThat(get_notification, Eventually(NotEquals(None)))
        notification = get_notification()
        self.assertThat(notification.opacity, Eventually(Equals(1.0)))

    def test_icon_summary(self):
        notify_list = self.get_notifications_list()
        self.unlock_greeter()

        summary = "Upload of image completed"
        hint_icon = self.get_icon_path('applicationIcons/facebook@18.png')

        notification = self.create_notification(summary)
        notification.set_hint('x-canonical-secondary-icon', GLib.Variant.new_string(hint_icon))
        notification.show()

        get_notification = lambda: notify_list.select_single('Notification')
        self.assertThat(get_notification, Eventually(NotEquals(None)))
        notification = get_notification()
        self.assertThat(notification.summary, Equals(summary))
        self.assertThat(notification.opacity, Eventually(Equals(1.0)))

    def test_low_urgency(self):
        notify_list = self.get_notifications_list()
        self.unlock_greeter()

        summary = "Low Urgency"
        body = "No, I'd rather see paint dry, pal *yawn*"
        icon_path = self.get_icon_path('avatars/anna_olsson@12.png')

        notification = self.create_notification(summary, body, icon_path, "LOW")
        notification.show()

        get_notification = lambda: notify_list.select_single('Notification')
        self.assertThat(get_notification, Eventually(NotEquals(None)))
        notification = get_notification()
        self.assertThat(notification.summary, Equals(summary))
        self.assertThat(notification.body, Equals(body))
        self.assertThat(notification.opacity, Eventually(Equals(1.0)))

    def test_normal_urgency(self):
        notify_list = self.get_notifications_list()
        self.unlock_greeter()

        summary = "Normal Urgency"
        body = "Hey pal, what's up with the party next weekend? Will you join me and Anna?"
        icon_path = self.get_icon_path('avatars/funky@12.png')

        notification = self.create_notification(summary, body, icon_path, "NORMAL")
        notification.show()

        get_notification = lambda: notify_list.select_single('Notification')
        self.assertThat(get_notification, Eventually(NotEquals(None)))
        notification = get_notification()
        self.assertThat(notification.summary, Equals(summary))
        self.assertThat(notification.body, Equals(body))
        self.assertThat(notification.opacity, Eventually(Equals(1.0)))

    def test_critical_urgency(self):
        notify_list = self.get_notifications_list()
        self.unlock_greeter()

        summary = 'Critical Urgency'
        body = 'Dude, this is so urgent you have no idea :)'
        icon_path = self.get_icon_path('avatars/amanda@12.png')

        notification = self.create_notification(summary, body, icon_path, "CRITICAL")
        notification.show()

        get_notification = lambda: notify_list.select_single('Notification')
        self.assertThat(get_notification, Eventually(NotEquals(None)))
        notification = get_notification()
        self.assertThat(notification.summary, Equals(summary))
        self.assertThat(notification.body, Equals(body))
        self.assertThat(notification.opacity, Eventually(Equals(1.0)))

    def test_summary_body(self):
        notify_list = self.get_notifications_list()
        self.unlock_greeter()

        summary = 'Summary-Body'
        body = 'This is a superfluous notification'

        notification = self.create_notification(summary, body)
        notification.show()

        get_notification = lambda: notify_list.select_single('Notification')
        self.assertThat(get_notification, Eventually(NotEquals(None)))
        notification = get_notification()
        self.assertThat(notification.summary, Equals(summary))
        self.assertThat(notification.body, Equals(body))
        self.assertThat(notification.opacity, Eventually(Equals(1.0)))

    def test_summary_only(self):
        notify_list = self.get_notifications_list()
        self.unlock_greeter()

        summary = 'Summary-Only'

        notification = self.create_notification(summary)
        notification.show()

        get_notification = lambda: notify_list.select_single('Notification')
        self.assertThat(get_notification, Eventually(NotEquals(None)))
        notification = get_notification()
        self.assertThat(notification.summary, Equals(summary))
        self.assertThat(notification.opacity, Eventually(Equals(1.0)))
