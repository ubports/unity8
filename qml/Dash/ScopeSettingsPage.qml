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

import QtQuick 2.4
import Ubuntu.Components 1.3
import Unity 0.2
import "../Components"
import "ScopeSettings"

Item {
    id: root

    property var scope: null
    property var scopeStyle: null

    signal backClicked()

    DashPageHeader {
        id: header
        objectName: "pageHeader"
        width: parent.width
        title: scope ? scope.name : ""
        showBackButton: true
        scopeStyle: root.scopeStyle

        onBackClicked: root.backClicked()
    }

    ListView {
        id: scopeSettings
        objectName: "scopeSettings"
        anchors {
            top: header.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        model: root.scope ? root.scope.settings : null
        clip: true

        ListViewOSKScroller {
            id: oskScroller
            list: scopeSettings
        }

        delegate: ScopeSettingsWidgetFactory {
            objectName: "scopeSettingItem" + index
            width: root.width
            widgetData: model
            scopeStyle: root.scopeStyle

            onUpdated: model.value = value;

            onMakeSureVisible: { // var item
                oskScroller.setMakeSureVisibleItem(item);
            }
        }
    }
}
