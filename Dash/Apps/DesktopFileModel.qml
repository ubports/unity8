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
import "../../Applications"

Item {
    id: root

    property var model: null
    property var baseModel: null

    ListModel {
        id: list

        Component.onCompleted: { root.model = list; }
    }

    Repeater {
        model: baseModel
        delegate: Item {
            Application {
                id: application
                desktopFile: model.desktopFile
            }
            Component.onCompleted: {
                list.append({"uri": model.desktopFile,
                             "icon": "../../graphics/applicationIcons/" + application.icon + ".png",
                             "category": 0,
                             "mimetype": "application/x-desktop",
                             "title": application.name,
                             "comment": "",
                             "dndUri": model.desktopFile,
                             "metadata": {}});
            }
        }
    }
}
