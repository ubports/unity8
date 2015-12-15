/*
 * Copyright (C) 2014, 2015 Canonical, Ltd.
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

import QtQuick 2.4

Image    {
    id: root

    fillMode: Image.PreserveAspectCrop

    property bool useHeight: false
    function updateUseHeight()
    {
        // Do not turn into a binding since otherwise the qml
        // engine complains about binding loops
        useHeight = (implicitWidth / implicitHeight) > (width / height);
    }

    onHeightChanged: updateUseHeight();
    onWidthChanged: updateUseHeight();
    onImplicitHeightChanged: updateUseHeight();
    onImplicitWidthChanged: updateUseHeight();

    sourceSize: useHeight ? Qt.size(0, height) : Qt.size(width, 0)
}
