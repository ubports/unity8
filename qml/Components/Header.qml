/*
 * Copyright (C) 2014 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import Ubuntu.Components 1.3
import Ubuntu.Components.Themes.Ambiance 1.3

PageHeadStyle {
    // FIXME: Don't use this but PageHeader from Ubuntu.Components 1.3.
    id: root

    property var styledItem: root
    property string title
    property var config: PageHeadConfiguration {}
    property var contents: null
}
