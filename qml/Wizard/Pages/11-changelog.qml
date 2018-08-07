/*
 * Copyright (C) 2015-2016 Canonical, Ltd.
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
import AccountsService 0.1
import ".." as LocalComponents

LocalComponents.Page {
    objectName: "changelogPage"
    title: i18n.tr("What's new")

    forwardButtonSourceComponent: forwardButton
    onlyOnUpdate: true


    Column {
        id: column
        spacing: units.gu(2)

        anchors {
            fill: content
            leftMargin: wideMode ? parent.leftMargin : staticMargin
            rightMargin: wideMode ? parent.rightMargin : staticMargin
            topMargin: staticMargin
        }

        Label {
            text: "This is where cool stuff would go"
        }
    }

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            text: i18n.tr("Next")
            onClicked: {
                if (d.validName) {
                    AccountsService.realName = d.validName;
                }
                pageStack.next();
            }
        }
    }
}
