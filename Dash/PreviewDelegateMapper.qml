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
    property var d: QtObject {
        readonly property string genericPreview: "Generic/GenericPreview.qml"
        readonly property string appPreview: "Apps/AppPreview.qml"
        property var previewDelegateMapping: {"preview-generic": genericPreview,
                                              "preview-application": appPreview,
                                              "preview-movie": "Movie/MoviePreview.qml",
        }
    }

    function map(rendererName) {
        var customPreview = d.previewDelegateMapping[rendererName]
        if (customPreview != undefined) {
            return customPreview
        }
        console.debug("Renderer "+rendererName+" not found, using preview-generic")
        return d.genericPreview
    }
}
