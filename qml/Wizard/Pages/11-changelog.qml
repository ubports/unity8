/*
 * Copyright (C) 2018 The UBports project
 *
 * Written by: Dalton Durst <dalton@ubports.com>
 *             Marius Gripsgard <marius@ubports.com>
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
import Wizard 0.1
import ".." as LocalComponents

LocalComponents.Page {
    objectName: "changelogPage"
    title: i18n.tr("What's new")
    id: changelogPage

    // See skipTimer below for information about this hack
    property bool loading: false

    forwardButtonSourceComponent: forwardButton
    onlyOnUpdate: true

    ScrollView {
        id: scroll

        anchors {
            fill: content
            leftMargin: wideMode ? parent.leftMargin : staticMargin
            rightMargin: wideMode ? parent.rightMargin : staticMargin
        }

        Column {
            id: column

            width: scroll.width

            // Make it appear that the text is hiding behind the header
            Item {
                height: staticMargin
                width: units.gu(1)
            }

            Label {
                anchors {
                    // Keep the scroll bar from interfering with text
                    rightMargin: units.gu(1)
                }
                id: changelogText
                width: parent.width
                wrapMode: Text.WordWrap
                textSize: Label.Medium
                text: Changelog.text
            }
        }
    }

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            text: loading ? i18n.tr("Loading...") : i18n.tr("Next")
            onClicked: {
                changelogPage.loading = true;
                skipTimer.restart();
            }
        }
    }

    // A horrible hack to make sure the UI refreshes before actually skipping
    // Without this, people press the Next button multiple times and skip
    // multiple pages at once.
    Timer {
        id: skipTimer
        interval: 100
        repeat: false
        running: false
        onTriggered: {
            changelogPage.loading = false;
            pageStack.next();
        }
    }
}
