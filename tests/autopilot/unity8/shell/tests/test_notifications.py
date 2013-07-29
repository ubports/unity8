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

from unity8.shell import with_lightdm_mock
from unity8.shell.tests import UnityTestCase, _get_device_emulation_scenarios

from testtools.matchers import Equals, NotEquals, GreaterThan, MismatchError
from testtools import skip
from autopilot.matchers import Eventually
from autopilot.platform import model

from gi.repository import GLib, Notify
import time
import os
from os import path
import logging
import signal
import subprocess

logger = logging.getLogger(__name__)


class TestNotifications(UnityTestCase):

    scenarios = _get_device_emulation_scenarios()
    action_interactive_triggered = False
    action_accept_triggered = False
    action_send_message_triggered = False
    loop = None

    def setUp(self):
        self. dbus_address = 'session'
        if model() == 'Desktop':
            p = subprocess.Popen(['dbus-launch'], stdout=subprocess.PIPE)
            output = p.communicate()
            results = output[0].split("\n")
            self.dbus_pid = int(results[1].split("=")[1])
            self.dbus_address = results[0].split("=", 1)[1]

            logger.info("Using DBUS_SESSION_BUS_ADDRESS: %s", self.dbus_address)
            logger.info("Using DBUS PID: %d", self.dbus_pid)

            self.patch_environment("DBUS_SESSION_BUS_ADDRESS", self.dbus_address)

            kill_dbus = lambda pid: os.killpg(pid, signal.SIGTERM)
            self.addCleanup(kill_dbus, self.dbus_pid)

        super(TestNotifications, self).setUp()
        self._notify_proc = None

    def tearDown(self):
        super(TestNotifications, self).tearDown()
        if self._notify_proc is not None and self._notify_proc.poll() is None:
            logger.error("Notification process wasn't killed.")
            os.killpg(self._notify_proc.pid, signal.SIGTERM)

    @with_lightdm_mock("single")
    def test_icon_summary_body(self):
        """Notification must display the expected summary and body text."""
        self.launch_unity(dbus_bus=self.dbus_address)
        greeter = self.main_window.get_greeter()
        greeter.unlock()

        notify_list = self._get_notifications_list()

        summary = "Icon-Summary-Body"
        body = "Hey pal, what's up with the party next weekend? Will you join me and Anna?"
        icon_path = self._get_icon_path('avatars/anna_olsson@12.png')
        hints = [
            (
                "x-canonical-secondary-icon",
                self._get_icon_path('applicationIcons/phone-app@18.png')
            )
        ]

        self._create_notification(
            summary,
            body,
            icon_path,
            "NORMAL",
            hints
        )

        get_notification = lambda: notify_list.select_single('Notification')
        self.assertThat(get_notification, Eventually(NotEquals(None)))
        notification = get_notification()
        self._assert_notification(notification, summary, body, True, True, 1.0)

    @with_lightdm_mock("single")
    def test_interactive(self):
        self.launch_unity(dbus_bus=self.dbus_address)
        greeter = self.main_window.get_greeter()
        greeter.unlock()

        notify_list = self._get_notifications_list()

        summary = "Summary"
        body = "Body"
        icon_path = self._get_icon_path('avatars/anna_olsson@12.png')
        hints = [
            ("x-canonical-switch-to-application", "true"),
            (
                "x-canonical-secondary-icon",
                self._get_icon_path('applicationIcons/phone-app@18.png')
            )
        ]

        self._create_interactive_notification(
            summary,
            body,
            icon_path,
            "NORMAL",
            hints,
            actions=[("action_id", "dummy")],
        )

        get_notification = lambda: notify_list.select_single('Notification')
        self.assertThat(get_notification, Eventually(NotEquals(None)))
        notification = get_notification()

        self.touch.tap_object(
            notification.select_single(objectName="interactiveArea")
        )

        self.assert_notification_action_id_was_called('action_id')

    @with_lightdm_mock("single")
    def test_sd_incoming_call(self):
        """Snap-decision simulating incoming call."""
        self.launch_unity()
        greeter = self.main_window.get_greeter()
        greeter.unlock()

        notify_list = self._get_notifications_list()

        summary = "Incoming call"
        body = "Frank Zappa\n+44 (0)7736 027340"
        icon_path = self._get_icon_path('avatars/anna_olsson@12.png')
        hints = [
            (
                "x-canonical-secondary-icon",
                self._get_icon_path('applicationIcons/phone-app@18.png')
            ),
            ("x-canonical-snap-decisions", "true"),
        ]

        actions = [
            ('action_accept', 'Accept'),
            ('action_decline_1', 'Decline'),
            ('action_decline_2', '"Can\'t talk now, what\'s up?"'),
            ('action_decline_3', '"I call you back."'),
            ('action_decline_4', 'Send custom message...'),
        ]

        self._create_interactive_notification(
            summary,
            body,
            icon_path,
            "NORMAL",
            actions,
            hints
        )

        get_notification = lambda: notify_list.select_single('Notification')
        self.assertThat(get_notification, Eventually(NotEquals(None)))
        notification = get_notification()
        #self._assert_notification(notification, None, None, True, True, 1.0)
        self.touch.tap_object(notification.select_single(objectName="button1"))
        #self.assertThat(notification.select_single(objectName="buttonRow").expanded, Eventually(Equals(True)))
        self.touch.tap_object(notification.select_single(objectName="button4"))
        #self.assertThat(self.action_send_message_triggered, Equals(True))
        self.assert_notification_action_id_was_called("action_decline_4")

    @with_lightdm_mock("single")
    def test_icon_summary(self):
        self.launch_unity(dbus_bus=self.dbus_address)
        greeter = self.main_window.get_greeter()
        greeter.unlock()

        notify_list = self._get_notifications_list()

        summary = "Upload of image completed"
        hints = [
            (
                "x-canonical-secondary-icon",
                self._get_icon_path('applicationIcons/facebook@18.png')
            )
        ]

        self._create_notification(
            summary,
            None,
            None,
            "NORMAL",
            hints
        )

        get_notification = lambda: notify_list.select_single('Notification')
        self.assertThat(get_notification, Eventually(NotEquals(None)))
        notification = get_notification()
        self._assert_notification(notification, summary, None, False, True, 1.0)

    @with_lightdm_mock("single")
    def test_urgency_order(self):
        self.launch_unity()
        greeter = self.main_window.get_greeter()
        greeter.unlock()
        Notify.init("Autopilot Notification Tests")
        notify_list = self._get_notifications_list()

        summary_low = 'Low Urgency'
        body_low = "No, I'd rather see paint dry, pal *yawn*"
        icon_path_low = self._get_icon_path('avatars/amanda@12.png')
        summary_normal = 'Normal Urgency'
        body_normal = "Hey pal, what's up with the party next weekend? Will you join me and Anna?"
        icon_path_normal = self._get_icon_path('avatars/funky@12.png')
        summary_critical = 'Critical Urgency'
        body_critical = 'Dude, this is so urgent you have no idea :)'
        icon_path_critical = self._get_icon_path('avatars/anna_olsson@12.png')

        notification_normal = self._create_ephemeral(summary_normal, body_normal, icon_path_normal, None, "NORMAL")
        notification_normal.show()
        notification_low = self._create_ephemeral(summary_low, body_low, icon_path_low, None, "LOW")
        notification_low.show()
        notification_critical = self._create_ephemeral(summary_critical, body_critical, icon_path_critical, None, "CRITICAL")
        notification_critical.show()

        time.sleep(4)
        get_notification = lambda: notify_list.select_single('Notification')
        self.assertThat(get_notification, Eventually(NotEquals(None)))
        notification = get_notification()
        self._assert_notification(notification, summary_critical, body_critical, True, False, 1.0)

        time.sleep(4)
        notification = get_notification()
        self._assert_notification(notification, summary_normal, body_normal, True, False, 1.0)

        time.sleep(4)
        notification = get_notification()
        self._assert_notification(notification, summary_low, body_low, True, False, 1.0)
        Notify.uninit()

    @with_lightdm_mock("single")
    def test_summary_body(self):
        self.launch_unity()
        greeter = self.main_window.get_greeter()
        greeter.unlock()
        Notify.init("Autopilot Notification Tests")
        notify_list = self._get_notifications_list()

        summary = 'Summary-Body'
        body = 'This is a superfluous notification'

        notification = self._create_ephemeral(summary, body)
        notification.show()

        get_notification = lambda: notify_list.select_single('Notification')
        self.assertThat(get_notification, Eventually(NotEquals(None)))
        notification = get_notification()
        self._assert_notification(notification, summary, body, False, False, 1.0)
        Notify.uninit()

    @with_lightdm_mock("single")
    def test_summary_only(self):
        self.launch_unity()
        greeter = self.main_window.get_greeter()
        greeter.unlock()
        Notify.init("Autopilot Notification Tests")
        notify_list = self._get_notifications_list()

        summary = 'Summary-Only'

        notification = self._create_ephemeral(summary)
        notification.show()

        get_notification = lambda: notify_list.select_single('Notification')
        self.assertThat(get_notification, Eventually(NotEquals(None)))
        notification = get_notification()
        self._assert_notification(notification, summary, '', False, False, 1.0)
        Notify.uninit()

    @with_lightdm_mock("single")
    def test_update_notification(self):
        self.launch_unity()
        greeter = self.main_window.get_greeter()
        greeter.unlock()
        Notify.init("Autopilot Notification Tests")
        notify_list = self._get_notifications_list()

        summary = 'Inital notification (1. notification)'
        body = 'This is the original content of this notification-bubble.'
        icon_path = self._get_icon_path('avatars/funky@12.png')
        notification = self._create_ephemeral(summary, body, icon_path)
        notification.show()
        get_notification = lambda: notify_list.select_single('Notification')
        self.assertThat(get_notification, Eventually(NotEquals(None)))
        self._assert_notification(get_notification(), summary, body, True, False, 1.0)

        time.sleep(3)
        summary = 'Updated notification (1. notification)'
        body = 'Here the same bubble with new title- and body-text, even the icon can be changed on the update.'
        icon_path = self._get_icon_path('avatars/amanda@12.png')
        notification.update(summary, body, icon_path)
        notification.show()
        self.assertThat(get_notification, Eventually(NotEquals(None)))
        self._assert_notification(get_notification(), summary, body)

        time.sleep(6)
        summary = 'Initial layout (2. notification)'
        body = 'This bubble uses the icon-title-body layout with a secondary icon.'
        icon_path = self._get_icon_path('avatars/anna_olsson@12.png')
        hint_icon = self._get_icon_path('applicationIcons/phone-app@18.png')
        notification = self._create_ephemeral(summary, body, icon_path)
        notification.set_hint('x-canonical-secondary-icon', GLib.Variant.new_string(hint_icon))
        notification.show()
        self.assertThat(get_notification, Eventually(NotEquals(None)))
        self._assert_notification(get_notification(), summary, body, True, True, 1.0)

        time.sleep(3)
        notification.clear_hints()
        summary = 'Updated layout (2. notification)'
        body = 'After the update we now have a bubble using the title-body layout.'
        notification.update(summary, body, None)
        notification.show()
        self.assertThat(get_notification, Eventually(NotEquals(None)))
        self._assert_notification(get_notification(), summary, body, False)
        Notify.uninit()

    @with_lightdm_mock("single")
    def test_append_hint(self):
        self.launch_unity()
        greeter = self.main_window.get_greeter()
        greeter.unlock()
        Notify.init("Autopilot Notification Tests")
        notify_list = self._get_notifications_list()

        summary = 'Cole Raby'
        body = 'Hey Bro Coly!'
        icon_path = self._get_icon_path('avatars/amanda@12.png')
        body_sum = body
        notification = self._create_ephemeral(summary, body, icon_path)
        notification.set_hint('x-canonical-append', GLib.Variant.new_string('true'))
        notification.show()
        get_notification = lambda: notify_list.select_single('Notification')
        self.assertThat(get_notification, Eventually(NotEquals(None)))
        notification = get_notification()
        self._assert_notification(notification, summary, body_sum, True, False, 1.0)

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
            notification = self._create_ephemeral(summary, body, icon_path)
            notification.set_hint('x-canonical-append', GLib.Variant.new_string('true'))
            notification.show()
            get_notification = lambda: notify_list.select_single('Notification')
            self.assertThat(get_notification, Eventually(NotEquals(None)))
            notification = get_notification()
            self._assert_notification(notification, summary, body_sum, True, False, 1.0)

        Notify.uninit()

    def _create_notification(
        self,
        summary="",
        body="",
        icon=None,
        urgency="NORMAL",
        hints=[]
    ):
        """Create a notification command.

        :param summary: Summary text for the notification
        :param body: Body text to display in the notification
        :param icon: Path string to the icon to use
        :param urgency: Urgency string for the noticiation, either: 'LOW',
            'NORMAL', 'CRITICAL'
        :param hint_strings: List of tuples containing the 'name' and value for
            setting the hint strings for the notification

        """
        logger.info(
            "Creating notification with summary(%s), body(%s) "
            "and urgency(%r)",
            summary,
            body,
            urgency
        )

        script_args = [
            '--summary', summary,
            '--body', body,
            '--urgency', urgency
        ]

        if icon is not None:
            script_args.extend(['--icon', icon])

        for hint in hints:
            key, value = hint
            script_args.extend(['--hint', "%s,%s" % (key, value)])

        command = [self._get_notify_script()] + script_args
        logger.info("Launching interactive notification as: %s", command)
        self._notify_proc = subprocess.Popen(
            command,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            close_fds=True,
            preexec_fn=os.setsid
        )


    def _create_interactive_notification(
        self,
        summary="",
        body="",
        icon=None,
        urgency="NORMAL",
        actions=[],
        hints=[]
    ):
        """Create a SnapDecision notification command.

        :param summary: Summary text for the notification
        :param body: Body text to display in the notification
        :param icon: Path string to the icon to use
        :param urgency: Urgency string for the noticiation, either: 'LOW',
            'NORMAL', 'CRITICAL'
        :param actions: List of tuples containing the 'id' and 'label' for all
            the actions to add
        :param hint_strings: List of tuples containing the 'name' and value for
            setting the hint strings for the notification

        """

        logger.info(
            "Creating snap-decision notification with summary(%s), body(%s) "
            "and urgency(%r)",
            summary,
            body,
            urgency
        )

        script_args = [
            '--summary', summary,
            '--body', body,
            '--urgency', urgency
        ]

        if icon is not None:
            script_args.extend(['--icon', icon])

        for hint in hints:
            key, value = hint
            script_args.extend(['--hint', "%s,%s" % (key, value)])

        for action in actions:
            action_id, action_label = action
            script_args.extend(['--action', "%s,%s" % (action_id, action_label)])

        command = [self._get_notify_script()] + script_args
        logger.info("Launching snap-decision notification as: %s", command)
        self._notify_proc = subprocess.Popen(
            command,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            close_fds=True,
            preexec_fn=os.setsid
        )
        if self._notify_proc.poll() is not None and self._notify_proc.returncode !=0:
            error_output = self._notify_proc.communicate()[1]
            raise RuntimeError("Call to script failed with: %s" % error_output)

    def _get_notify_script(self):
        """Returns the path to the interactive notification creation script."""
        file_path = "../../emulators/create_interactive_notification.py"

        the_path = os.path.abspath(
            os.path.join(__file__, file_path))

        return the_path

    def assert_notification_action_id_was_called(self, action_id, timeout=10):
        """Assert that the interactive notification callback of id *action_id*
        was called.

        :raises AssertionError: If no interactive notification has actually been
            created.
        :raises AssertionError: When *action_id* does not match the actual
            returned.
        :raises AssertionError: If no callback was called at all.
        """

        if self._notify_proc is None:
            raise AssertionError("No interactive notification was created.")

        for i in xrange(timeout):
            self._notify_proc.poll()
            if self._notify_proc.returncode is not None:
                output = self._notify_proc.communicate()
                actual_action_id = output[0].strip("\n")
                if actual_action_id != action_id:
                    raise AssertionError(
                        "action id '%s' does not match actual returned '%s'"
                        % (action_id, actual_action_id)
                    )
                else:
                    return
            time.sleep(1)

        os.killpg(self._notify_proc.pid, signal.SIGTERM)
        self._notify_proc = None
        raise AssertionError(
            "No callback was called, killing interactivenotification script"
        )

    def _create_ephemeral(self, summary="", body="", icon=None, secondary_icon=None, urgency="NORMAL"):
        logger.info("Creating ephemeral notification with summary(%s), body(%s) and urgency(%r)", summary, body, urgency)
        if icon is not None:
            logger.info("Using icon(%s)", icon)
        if secondary_icon is not None:
            logger.info("Using secondary-icon(%s)", secondary_icon)

        n = Notify.Notification.new(summary, body, icon)
        if secondary_icon is not None:
            n.set_hint('x-canonical-secondary-icon', GLib.Variant.new_string(secondary_icon))
        n.set_urgency(self._get_urgency(urgency))

        return n

    def _create_confirmation(self, summary="", body="", icon=None, secondary_icon=None, urgency="NORMAL"):
        logger.info("Creating confirmation notification with summary(%s), body(%s) and urgency(%r)", summary, body, urgency)
        if icon is not None:
            logger.info("Using icon(%s)", icon)
        if secondary_icon is not None:
            logger.info("Using secondary-icon(%s)", secondary_icon)

        n = Notify.Notification.new(summary, body, icon)
        if secondary_icon is not None:
            n.set_hint('x-canonical-secondary-icon', GLib.Variant.new_string(secondary_icon))
        n.set_hint('x-canonical-private-synchronous', GLib.Variant.new_string('true'))
        if summary == "" and body == "":
            n.set_hint('x-canonical-private-icon-only', GLib.Variant.new_string('true'))
        n.set_urgency(self._get_urgency(urgency))

        return n

    def _get_urgency(self, urgency):
        """Translates urgency string to enum."""
        _urgency_enums = {'LOW': Notify.Urgency.LOW,
                          'NORMAL': Notify.Urgency.NORMAL,
                          'CRITICAL': Notify.Urgency.CRITICAL}
        return _urgency_enums.get(urgency.upper())

    def _get_icon_path(self, icon_name):
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

    def _get_notifications_list(self):
        main_view = self.main_window.get_qml_view()
        return main_view.select_single("QQuickListView", objectName='notificationList')

    def _assert_notification(self, notification, summary=None, body=None, icon=True, secondary_icon=False, opacity=None):
        if summary is not None:
            self.assertThat(notification.summary, Equals(summary))

        if body is not None:
            self.assertThat(notification.body, Equals(body))

        if icon:
            self.assertThat(notification.iconSource, NotEquals(""))
        else:
            self.assertThat(notification.iconSource, Equals(""))

        if secondary_icon:
            self.assertThat(notification.secondaryIconSource, NotEquals(""))
        else:
            self.assertThat(notification.secondaryIconSource, Equals(""))

        if opacity is not None:
            self.assertThat(notification.opacity, Eventually(Equals(opacity)))
