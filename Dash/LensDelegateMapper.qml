/*
 * Copyright (C) 2013 Canonical, Ltd.
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

import QtQuick 2.0

QtObject {
    property var lensDelegateMapping: {"mockmusic.lens": "DashMusic.qml",
                                       "applications.lens": "DashApps.qml",
                                       "home.lens": "DashHome.qml",
                                       "mockvideos.lens": "DashVideos.qml",
                                       "people.lens": "DashPeople.qml",
                                      }
    property string genericLens: "GenericLensView.qml"

    function map(lensId) {
        var customLens = lensDelegateMapping[lensId]
        if (customLens != undefined) {
            return customLens
        }
        return genericLens
    }
}
