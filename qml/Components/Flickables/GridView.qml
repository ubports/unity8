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

import QtQuick 2.3 as QtQuick
import Ubuntu.Components 1.1

QtQuick.GridView {
    // Attached components and usages like GridView.onRemove are known not to work
    // please use GridView directly from QtQuick if needed
    flickDeceleration: 1500 * units.gridUnit / 8
    maximumFlickVelocity: 2500 * units.gridUnit / 8
}
