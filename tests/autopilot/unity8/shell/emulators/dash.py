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
from autopilot.introspection import dbus


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
        scope_loader = self._get_scope_loader(scope_id)
        if scope_loader.isCurrent:
            logger.info('The scope is already open.')
            return self._get_scope_from_loader(scope_loader)
        else:
            return self._open_scope_scrolling(scope_loader)

    def _get_scope_loader(self, scope_id):
        try:
            return self.dash_content_list.select_single(
                'QQuickLoader', scopeId=scope_id)
        except dbus.StateNotFoundError:
            raise emulators.UnityEmulatorException(
                'No scope found with id {0}'.format(scope_id))

    def _get_scope_from_loader(self, loader):
        if loader.scopeId == 'applications.scope':
            return loader.select_single(DashApps)
        else:
            return loader.select_single(GenericScopeView)

    def _open_scope_scrolling(self, scope_loader):
        scroll = self._get_scroll_direction(scope_loader)

        while not scope_loader.isCurrent:
            scroll()
            self.dash_content_list.moving.wait_for(False)

        scope = self._get_scope_from_loader(scope_loader)
        scope.isCurrent.wait_for(True)
        return scope

    def _get_scroll_direction(self, scope_loader):
        current_scope_loader = self.dash_content_list.select_single(
            'QQuickLoader', isCurrent=True)
        if scope_loader.globalRect.x < current_scope_loader.globalRect.x:
            return self._scroll_to_left_scope
        elif scope_loader.globalRect.x > current_scope_loader.globalRect.x:
            return self._scroll_to_right_scope
        else:
            raise emulators.UnityEmulatorException('The scope is already open')

    @autopilot_logging.log_action(logger.info)
    def _scroll_to_left_scope(self):
        original_index = self.dash_content_list.currentIndex
        # Scroll on the border of the page header, because some scopes have
        # contents that can be scrolled horizontally.
        page_header = self.select_single('PageHeader')
        border = page_header.select_single('QQuickBorderImage')
        start_x = border.width / 3
        stop_x = border.width / 3 * 2
        start_y = stop_y = border.globalRect.y + border.height / 2
        self.pointing_device.drag(start_x, start_y, stop_x, stop_y)
        self.dash_content_list.currentIndex.wait_for(original_index - 1)

    @autopilot_logging.log_action(logger.info)
    def _scroll_to_right_scope(self):
        original_index = self.dash_content_list.currentIndex
        # Scroll on the border of the page header, because some scopes have
        # contents that can be scrolled horizontally.
        page_header = self.select_single('PageHeader')
        border = page_header.select_single('QQuickBorderImage')
        start_x = border.width / 3 * 2
        stop_x = border.width / 3
        start_y = stop_y = border.globalRect.y + border.height / 2
        self.pointing_device.drag(start_x, start_y, stop_x, stop_y)
        self.dash_content_list.currentIndex.wait_for(original_index + 1)


class DashPreview(emulators.UnityEmulatorBase):
    """Autopilot emulator for the generic preview."""

    def get_details(self):
        """Return the details of the open preview."""
        title = self.select_single('Label', objectName='titleLabel').text
        subtitle = self.select_single(
            'Label', objectName='subtitleLabel').text
        description = self.select_single(
            'Label', objectName='descriptionLabel').text
        return dict(title=title, subtitle=subtitle, description=description)


class GenericScopeView(emulators.UnityEmulatorBase):
    """Autopilot emulator for generic scopes."""

    preview_class = DashPreview

    @autopilot_logging.log_action(logger.info)
    def open_preview(self, category, app_name):
        """Open the preview of an application.

        :parameter category: The name of the category where the application is.
        :app_name: The name of the application.

        """
        category_element = self._get_category_element(category)
        icon = category_element.select_single('Tile', text=app_name)
        # FIXME some categories need a long press in order to see the preview.
        # Some categories do not show previews, like recent apps.
        # --elopio - 2014-1-14
        self.pointing_device.click_object(icon)
        preview = self.get_root_instance().wait_select_single(
            self.preview_class, isCurrent=True)
        preview.showProcessingAction.wait_for(False)
        return preview

    def _get_category_element(self, category):
        try:
            return self.wait_select_single(
                'Base', objectName='dashCategory{}'.format(category))
        except dbus.StateNotFoundError:
            raise emulators.UnityEmulatorException(
                'No category found with name {}'.format(category))


class AppPreview(DashPreview):
    """Autopilot emulator for the application preview."""

    def get_details(self):
        """Return the details of the application showed in its preview."""
        details = super(AppPreview, self).get_details()
        # TODO return screenshots, icon, rating and reviews.
        # --elopio - 2014-1-15
        return dict(
            title=details.get('title'), publisher=details.get('subtitle'),
            description=details.get('description'))


class DashApps(GenericScopeView):
    """Autopilot emulator for the applications scope."""

    preview_class = AppPreview

    def get_applications(self, category):
        """Return the list of applications on a category.

        :parameter category: The name of the category.

        """
        category_element = self._get_category_element(category)
        application_tiles = category_element.select_many('Tile')
        # TODO return them on the same order they are displayed.
        # --elopio - 2014-1-15
        return [tile.text for tile in application_tiles]
