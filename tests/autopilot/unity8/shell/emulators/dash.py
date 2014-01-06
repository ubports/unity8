# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity Autopilot Test Suite
# Copyright (C) 2012, 2013, 2014 Canonical
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

from unity8.shell import emulators

from autopilot import logging as autopilot_logging


logger = logging.getLogger(__name__)


class Dash(emulators.UnityEmulatorBase):
    """An emulator that understands the Dash."""

    def __init__(self, *args):
        super(Dash, self).__init__(*args)
        self.dash_content_list = self.wait_select_single(
            'QQuickListView', objectName='dashContentList')

    def get_home_applications_grid(self):
        get_grid = self.get_scope('home').wait_select_single(
            "GenericFilterGrid",
            objectName="applications.scope"
        )
        return get_grid

    def get_application_icon(self, text):
        """Returns a 'Tile' icon that has the text 'text' from the application
        grid.

        :param text: String containing the text of the icon to search for.

        """
        app_grid = self.get_home_applications_grid()
        resp_grid = app_grid.wait_select_single('ResponsiveGridView')
        return resp_grid.select_single('Tile', text=text)

    def get_scope(self, scope_name='home'):
        scope_id = "%s.scope" % scope_name
        return self.dash_content_list.select_single(
            'QQuickLoader', scopeId=scope_id)

    @autopilot_logging.log_action(logger.info)
    def open_scope(self, scope_name):
        """Open a dash scope.

        :parameter scope_name: The name of the scope.
        :return: The scope.

        """
        scope_id = "%s.scope" % scope_name
        scope_index = self._get_scope_index(scope_id)
        if scope_index == self.dash_content_list.currentIndex:
            logger.info('The scope is already open.')
            return self._get_scope_by_index(scope_index)
        else:
            return self._open_scope_scrolling(scope_index)

    def _get_scope_index(self, scope_id):
        scope_loaders = self.dash_content_list.select_many('QQuickLoader')
        for index, loader in enumerate(scope_loaders):
            try:
                if loader.scopeId == scope_id:
                    return index
            except AttributeError:
                pass
        else:
            raise emulators.UnityEmulatorException(
                'No scope found with id {0}'.format(scope_id))

    def _get_scope_by_index(self, scope_index):
        scope_loaders = self.dash_content_list.select_many('QQuickLoader')
        return self._get_scope_from_loader(scope_loaders[scope_index])

    def _get_scope_from_loader(self, loader):
        if loader.scopeId == 'applications.scope':
            return loader.select_single(DashApps)
        else:
            return loader.select_single(GenericScopeView)

    def _open_scope_scrolling(self, scope_index):
        scroll = self._get_scroll_direction(scope_index)

        while scope_index != self.dash_content_list.currentIndex:
            scroll()
        scope = self._get_scope_by_index(scope_index)
        scope.moving.wait_for(False)
        scope.isCurrent.wait_for(True)
        return scope

    def _get_scroll_direction(self, scope_index):
        if scope_index < self.dash_content_list.currentIndex:
            return self._scroll_to_left_scope
        elif scope_index > self.dash_content_list.currentIndex:
            return self._scroll_to_right_scope
        else:
            raise emulators.UnityEmulatorException('The scope is already open')

    @autopilot_logging.log_action(logger.info)
    def _scroll_to_left_scope(self):
        original_index = self.dash_content_list.currentIndex
        # Scroll on the dash bar, because some scopes have contents that can be
        # scrolled horizontally.
        panel = self.select_single('DashBar').select_single('Panel')
        start_x = panel.width / 3
        stop_x = panel.width / 3 * 2
        start_y = stop_y = panel.globalRect.y + panel.height / 2
        self.pointing_device.drag(start_x, start_y, stop_x, stop_y)
        self.dash_content_list.currentIndex.wait_for(original_index - 1)
        panel.opened.wait_for(False)

    @autopilot_logging.log_action(logger.info)
    def _scroll_to_right_scope(self):
        original_index = self.dash_content_list.currentIndex
        # Scroll on the dash bar panel, because some scopes have contents that
        # can be scrolled horizontally.
        panel = self.select_single('DashBar').select_single('Panel')
        start_x = panel.width / 3 * 2
        stop_x = panel.width / 3
        start_y = stop_y = panel.globalRect.y + panel.height / 2
        self.pointing_device.drag(start_x, start_y, stop_x, stop_y)
        self.dash_content_list.currentIndex.wait_for(original_index + 1)
        panel.opened.wait_for(False)


class GenericScopeView(emulators.UnityEmulatorBase):
    """Autopilot emulators for generic scopes."""


class DashApps(emulators.UnityEmulatorBase):
    """Autopilot emulators for the applications scope."""
