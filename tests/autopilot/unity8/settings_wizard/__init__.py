# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity Autopilot Test Suite
# Copyright (C) 2015 Canonical
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

import logging
import re

import autopilot
from autopilot import introspection
from ubuntuuitoolkit import UbuntuUIToolkitCustomProxyObjectBase

from contextlib import contextmanager


logger = logging.getLogger(__name__)


@contextmanager
def override_proxy_timeout(proxy, timeout_seconds):
    original_timeout = proxy._poll_time
    try:
        proxy._poll_time = timeout_seconds
        yield proxy
    finally:
        proxy._poll_time = original_timeout


def get_wizard(current_page):
    return current_page.get_root_instance().select_single(Wizard)


class Wizard(UbuntuUIToolkitCustomProxyObjectBase):
    """High-level helper to navigate through the pages of the wizard"""

    def get_language_page(self):
        return self.wait_select_single(
            objectName='languagePage', visible='True')

    def get_current_page(self):
        return self.wait_select_single('Page', visible='True')

    def get_sim_page(self):
        return self.wait_select_single(
            objectName='simPage', visible='True')

    def get_password_page(self):
        return self.wait_select_single(
            objectName='passwdPage', visible='True')

    def get_password_entry_page(self):
        return self.wait_select_single(
            objectName='passwdSetPage', visible='True')

    def get_confirm_password_page(self):
        return self.wait_select_single(
            objectName='passwdConfirmPage', visible='True')

    def get_wifi_connect_page(self):
        return self.wait_select_single(
            objectName='wifiPage', visible='True')

    def get_location_page(self):
        return self.wait_select_single(
            objectName='locationPage', visible='True')

    def get_reporting_page(self):
        return self.wait_select_single(
            objectName='reportingPage', visible='True')

    def get_finished_page(self):
        return self.wait_select_single(
            objectName='finishedPage', visible='True')


class WizardLanguagePage(UbuntuUIToolkitCustomProxyObjectBase):
    """Helper class to interact with the language welcome page"""

    # This class was renamed from LanguagePage to WizardLanguagePage because
    # there is a class with the same name in the system settings custom proxy
    # objects. Reported in http://pad.lv/1422904. --elopio - 2015-02-17

    @classmethod
    def validate_dbus_object(cls, path, state):
        name = introspection.get_classname_from_path(path)
        if name == b'Page':
            if state['objectName'][1] == 'languagePage':
                return True
        return False

    def _get_language_button(self):
        return self.select_single(
            'ComboButton', objectName='languageCombo')

    def _get_continue_button(self):
        return self.select_single('StackButton', text='Continue')

    def _swipe_to_language(self, list, language):
        """Swipe to the chosen language in the given list"""
        list.swipe_to_top()
        while not list.atYEnd:
            try:
                item = list.select_single(
                    'LabelVisual', text=language, visible='True')
                item.swipe_into_view()
                return item
            except introspection.dbus.StateNotFoundError:
                list.swipe_to_show_more_below()
        # item could not be found
        raise introspection.dbus.StateNotFoundError

    @autopilot.logging.log_action(logger.info)
    def select_language(self, language):
        """Select a different language from the list"""
        combo_button = self._get_language_button()
        self.pointing_device.click_object(combo_button)
        language_list = combo_button.wait_select_single(
            'UbuntuListView11', visible='True')
        item = self._swipe_to_language(language_list, language)
        self.pointing_device.click_object(item)

    def get_selected_language(self):
        return self._get_language_button().get_properties()['text']

    @autopilot.logging.log_action(logger.info)
    def continue_(self):
        self.pointing_device.click_object(self._get_continue_button())
        wizard = get_wizard(self)
        next_page = wizard.get_current_page()
        sim_inserted = True
        if next_page.objectName == 'simPage':
            # no sim is inserted
            next_page = wizard.get_sim_page()
            sim_inserted = False
        else:
            # sim is inserted
            next_page = wizard.get_password_page()
        return sim_inserted, next_page


class SimPage(UbuntuUIToolkitCustomProxyObjectBase):
    """Helper class to interact with the no sim notification page"""

    @classmethod
    def validate_dbus_object(cls, path, state):
        name = introspection.get_classname_from_path(path)
        if name == b'Page':
            if state['objectName'][1] == 'simPage':
                return True
        return False

    def _get_back_button(self):
        return self.select_single('StackButton', text='Back')

    def _get_skip_button(self):
        return self.select_single('StackButton', text='Skip')

    @autopilot.logging.log_action(logger.info)
    def back(self):
        self.pointing_device.click_object(self._get_back_button())
        return get_wizard(self).get_languge_page()

    @autopilot.logging.log_action(logger.info)
    def skip(self):
        self.pointing_device.click_object(self._get_skip_button())
        return get_wizard(self).get_password_page()


class PasswordPage(UbuntuUIToolkitCustomProxyObjectBase):
    """Helper class to interact with the password security page"""

    SECURITY_SWIPE = 'Swipe'
    SECURITY_PASSCODE = 'Passcode'
    SECURITY_PASSPHRASE = 'Passphrase'

    @classmethod
    def validate_dbus_object(cls, path, state):
        name = introspection.get_classname_from_path(path)
        if name == b'Page':
            if state['objectName'][1] == 'passwdPage':
                return True
        return False

    def _get_option_name(self, formatted_name):
        # the option name is formatted as follows:
        # need to read the name between bold tags
        # '<b>Passcode</b> (4 digits only)'
        formatted_pattern = re.compile(r'<b>(.*?)</b>.*',
                                       re.IGNORECASE | re.DOTALL)
        name = None
        match = formatted_pattern.search(formatted_name)
        if match:
            name = match.group(1)
        return name

    def _get_all_options(self):
        return self.select_many('OptionSelectorDelegate')

    def _get_continue_button(self):
        return self.select_single('StackButton', text='Continue')

    def _get_back_button(self):
        return self.select_single('StackButton', text='Back')

    def _get_selected_option(self):
        return self.select_single(
            'OptionSelectorDelegate', visible='True', selected='True')

    def get_selected_security_option(self):
        name_fmt = self._get_selected_option().get_properties()['subText']
        return self._get_option_name(name_fmt)

    @autopilot.logging.log_action(logger.info)
    def select_security_option(self, selected_option):
        options = self._get_all_options()
        for option in options:
            name = self._get_option_name(option.get_properties()['subText'])
            if name == selected_option:
                self.pointing_device.click_object(option)

    @autopilot.logging.log_action(logger.info)
    def back(self, sim_inserted):
        self.pointing_device.click_object(self._get_back_button())
        wizard = get_wizard(self)
        if sim_inserted:
            page = wizard.get_languge_page()
        else:
            page = wizard.get_sim_page()
        return page

    @autopilot.logging.log_action(logger.info)
    def continue_(self):
        option = self.get_selected_security_option()
        self.pointing_device.click_object(self._get_continue_button())
        wizard = get_wizard(self)
        if option == self.SECURITY_SWIPE:
            next_page = wizard.get_wifi_connect_page()
        else:
            next_page = wizard.get_password_entry_page()
        return next_page


class PasswordEntryPage(UbuntuUIToolkitCustomProxyObjectBase):
    """Helper class to interact with the pin entry page"""

    @classmethod
    def validate_dbus_object(cls, path, state):
        name = introspection.get_classname_from_path(path)
        if name == b'Page':
            if state['objectName'][1] == 'passwdSetPage':
                return True
        return False

    def _get_pinpad_button(self, char):
        return self.select_single('PinPadButton', text=char)

    def _get_continue_button(self):
        return self.select_single('StackButton', text='Continue')

    def _get_back_button(self):
        return self.select_single('StackButton', text='Back')

    def _get_text_field(self):
        return self.select_single('QQuickTextInput')

    @autopilot.logging.log_action(logger.info)
    def enter_pin(self, pin):
        for char in pin:
            self.pointing_device.click_object(self._get_pinpad_button(char))
        return get_wizard(self).get_confirm_password_page()

    @autopilot.logging.log_action(logger.info)
    def enter_text(self, text):
        self.pointing_device.click_object(self._get_text_field())
        autopilot.input.Keyboard.create().type(text)

    @autopilot.logging.log_action(logger.info)
    def back(self):
        self.pointing_device.click_object(self._get_back_button())
        return get_wizard(self).get_password_page()

    @autopilot.logging.log_action(logger.info)
    def continue_(self):
        autopilot.input.Keyboard.create().press_and_release('Enter')
        return get_wizard(self).get_confirm_password_page()


class ConfirmPasswordPage(UbuntuUIToolkitCustomProxyObjectBase):
    """Helper class to interact with the pin confirmation page"""

    @classmethod
    def validate_dbus_object(cls, path, state):
        name = introspection.get_classname_from_path(path)
        if name == b'Page':
            if state['objectName'][1] == 'passwdConfirmPage':
                return True
        return False

    def _get_pinpad_button(self, char):
        return self.select_single('PinPadButton', text=char)

    def _get_continue_button(self):
        return self.select_single('StackButton', text='Continue')

    def _get_back_button(self):
        return self.select_single('StackButton', text='Back')

    def _get_text_field(self):
        return self.select_single('QQuickTextInput')

    @autopilot.logging.log_action(logger.info)
    def enter_pin(self, pin):
        for char in pin:
            self.pointing_device.click_object(self._get_pinpad_button(char))
        return get_wizard(self).get_wifi_connect_page()

    @autopilot.logging.log_action(logger.info)
    def enter_text(self, text):
        self.pointing_device.click_object(self._get_text_field())
        autopilot.input.Keyboard.create().type(text)

    @autopilot.logging.log_action(logger.info)
    def back(self):
        self.pointing_device.click_object(self._get_back_button())
        return get_wizard(self).get_password_page()

    @autopilot.logging.log_action(logger.info)
    def continue_(self):
        autopilot.input.Keyboard.create().press_and_release('Enter')
        return get_wizard(self).get_wifi_connect_page()


class WifiConnectPage(UbuntuUIToolkitCustomProxyObjectBase):
    """Helper class to interact with the Wi-Fi network list page"""

    @classmethod
    def validate_dbus_object(cls, path, state):
        name = introspection.get_classname_from_path(path)
        if name == b'Page':
            if state['objectName'][1] == 'wifiPage':
                return True
        return False

    def _get_all_networks(self):
        try:
            networks = self.select_many('Standard', objectName='accessPoint',
                                        visible='True')
        except:
            networks = []
        return networks

    def _get_network(self, ssid):
        return self.wait_select_single(
            'Standard', objectName='accessPoint', text=ssid, visible='True')

    def _get_network_checkbox(self, ssid):
        return self._get_network(ssid).select_single(
            'CheckBox', visible='True')

    def _get_next_page(self):
        wizard = get_wizard(self)
        next_page = wizard.get_current_page()
        locationPageEnabled = True
        reportingPageEnabled = True
        if next_page.objectName == 'locationPage':
            next_page = wizard.get_location_page()
        else:
            locationPageEnabled = False
            if next_page.objectName == 'reportingPage':
                next_page = wizard.get_reporting_page()
            else:
                reportingPageEnabled = False
                next_page = wizard.get_finished_page()
        return locationPageEnabled, reportingPageEnabled, next_page

    def _get_notification(self, unity):
        logger.info('Waiting longer for notification object')
        with override_proxy_timeout(unity, 30):
            return unity.wait_select_single(
                Notification, objectName='notification1', visible='True')

    def _get_back_button(self):
        return self.wait_select_single(
            'StackButton', text='Back', visible='True')

    def _get_continue_button(self):
        return self.wait_select_single(
            'StackButton', text='Continue', visible='True')

    def _get_skip_button(self):
        return self.wait_select_single(
            'StackButton', text='Skip', visible='True')

    def is_any_network_checked(self):
        networks = self._get_all_networks()
        for network in networks:
            checkbox = network.select_single('CheckBox', visible='True')
            if checkbox.get_properties()['checked']:
                return True
        return False

    def is_any_network_found(self):
        num_neworks = len(self._get_all_networks())
        return True if num_neworks > 0 else False

    def is_network_checked(self, ssid):
        return self._get_network_checkbox(ssid).get_properties()['checked']

    @autopilot.logging.log_action(logger.info)
    def select_network(self, unity, ssid):
        self.pointing_device.click_object(self._get_network_checkbox(ssid))
        return PasswordNotification(self._get_notification(unity))

    @autopilot.logging.log_action(logger.info)
    def back(self):
        self.pointing_device.click_object(self._get_back_button())
        return get_wizard(self).get_password_page()

    @autopilot.logging.log_action(logger.info)
    def skip(self):
        self.pointing_device.click_object(self._get_skip_button())
        return self._get_next_page()

    @autopilot.logging.log_action(logger.info)
    def continue_(self):
        self.pointing_device.click_object(self._get_continue_button())
        return self._get_next_page()


class LocationPage(UbuntuUIToolkitCustomProxyObjectBase):
    """Helper class to interact with the LocationPage"""

    @classmethod
    def validate_dbus_object(cls, path, state):
        name = introspection.get_classname_from_path(path)
        if name == b'Page':
            if state['objectName'][1] == 'locationPage':
                return True
        return False

    def _get_back_button(self):
        return self.select_single('StackButton', text='Back')

    def _get_continue_button(self):
        return self.select_single('StackButton', text='Continue')

    @autopilot.logging.log_action(logger.info)
    def back(self):
        self.pointing_device.click_object(self._get_back_button())
        return get_wizard(self).get_wifi_connect_page()

    @autopilot.logging.log_action(logger.info)
    def continue_(self):
        self.pointing_device.click_object(self._get_continue_button())
        return get_wizard(self).get_reporting_page()


class Notification(UbuntuUIToolkitCustomProxyObjectBase):
    """Base class for notification objects"""
    pass


class PasswordNotification(Notification):
    """Helper class to interact with the password entry notification"""

    def __init__(self, notification):
        self.notification = notification

    def _get_connect_button(self):
        return self.notification.wait_select_single(
            'Button', text='Connect', objectName='notify_button0')

    def _get_cancel_buttoon(self):
        return self.notification.wait_select_single(
            'Button', text='Cancel', objectName='notify_button1')

    def _get_text_field(self):
        return self.notification.wait_select_single('TextField')

    @autopilot.logging.log_action(logger.info)
    def enter_text(self, text):
        self._get_text_field().write(text)

    @autopilot.logging.log_action(logger.info)
    def connect(self):
        self.notification.pointing_device.click_object(
            self._get_connect_button())

    @autopilot.logging.log_action(logger.info)
    def cancel(self):
        self.notification.pointing_device.click_object(
            self._get_cancel_buttoon())


class ReportingPage(UbuntuUIToolkitCustomProxyObjectBase):
    """Helper class to interact with the reporting page"""

    @classmethod
    def validate_dbus_object(cls, path, state):
        name = introspection.get_classname_from_path(path)
        if name == b'Page':
            if state['objectName'][1] == 'reportingPage':
                return True
        return False

    def _get_continue_button(self):
        return self.select_single('StackButton', text='Continue')

    def _get_back_button(self):
        return self.select_single('StackButton', text='Back')

    @autopilot.logging.log_action(logger.info)
    def back(self):
        self.pointing_device.click_object(self._get_back_button())
        return get_wizard(self).get_wifi_connect_page()

    @autopilot.logging.log_action(logger.info)
    def continue_(self):
        self.pointing_device.click_object(self._get_continue_button())
        return get_wizard(self).get_finished_page()


class FinishedPage(UbuntuUIToolkitCustomProxyObjectBase):
    """Helper class to interact with the finished page"""

    @classmethod
    def validate_dbus_object(cls, path, state):
        name = introspection.get_classname_from_path(path)
        if name == b'Page':
            if state['objectName'][1] == 'finishedPage':
                return True
        return False

    def _get_finish_button(self):
        return self.wait_select_single(
            'StackButton', text='Finish', visible='True')

    @autopilot.logging.log_action(logger.info)
    def finish(self):
        self.pointing_device.click_object(self._get_finish_button())
        self.wait_until_destroyed()
