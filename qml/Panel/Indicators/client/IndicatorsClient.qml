/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Renato Araujo Oliveira Filho <renato@canonical.com>
 */

import QtQuick 2.12
import Ubuntu.Components 1.3

Rectangle {
    id: root
    color: theme.palette.normal.background

    Component.onCompleted: {
        theme.name = "Ubuntu.Components.Themes.SuruDark"
    }

    PageStack {
        id: pages
        anchors.fill: parent
        Component.onCompleted: reset()

        function reset() {
            clear();
            var component = Qt.createComponent("IndicatorsList.qml");
            if (component.status !== Component.Ready) {
                if (component.status === Component.Error)
                    console.error("Error: " + component.errorString());

                return;
            }

            var page = component.createObject(pages, {"profile": indicatorProfile});
            push(page);
        }
    }
}
