# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Unity Autopilot Test Suite
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

from unity8.shell.emulators import UnityEmulatorBase


class Dash(UnityEmulatorBase):

    """An emulator that understands the Dash."""

    def get_home_applications_grid(self):
        return self.select_single(
            "ApplicationsFilterGrid",
            objectName="dashHomeApplicationsGrid"
        )

    def get_application_icon(self, text):
        """Returns a 'Tile' icon that has the text 'text' from the application
        grid.

        Will return None if the icon isn't found.

        :param text: String containing the text of the icon to search for.

        """
        app_grid = self.get_home_applications_grid()
        resp_grid = app_grid.select_single('ResponsiveGridView')
        return resp_grid.select_single('Tile', text=text)

    def get_scope(self, scope_name='home'):
        dash_content = self.select_single(
            'QQuickListView',
            objectName='dashContentList'
        )
        scope_id = "%s.scope" % scope_name
        return dash_content.select_single('QQuickLoader', scopeId=scope_id)
