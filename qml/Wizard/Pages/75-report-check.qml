/*
 * Copyright (C) 2015 Canonical, Ltd.
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

import QtQuick 2.3
import Ubuntu.Components 1.2
import Ubuntu.Web 0.2
import Ubuntu.SystemSettings.Diagnostics 1.0
import ".." as LocalComponents

LocalComponents.Page {
    id: reportCheckPage
    objectName: "reportCheckPage"

    title: webview.visible ? i18n.tr("Privacy Policy") : i18n.tr("Help Us Improve")
    forwardButtonSourceComponent: !webview.visible ? forwardButton : null
    customBack: true
    customTitle: webview.visible

    onBackClicked: {
        if (webview.visible) {
            webview.visible = false;
        } else {
            pageStack.prev();
        }
    }

    UbuntuDiagnostics {
        id: diagnostics
        objectName: "diagnostics"
    }

    Column {
        id: column
        anchors {
            fill: content
            leftMargin: leftMargin
            rightMargin: rightMargin
            topMargin: customMargin
        }

        LocalComponents.CheckableSetting {
            anchors {
                left: parent.left
                right: parent.right
            }

            id: reportCheck
            objectName: "reportCheck"
            showDivider: false
            text: i18n.tr("Improve system performance by sending us crashes and error reports.") + "<br><br><a href='#'>" +
                  i18n.tr("Privacy policy") + "</a>"
            checked: true
            onLinkActivated: {
                webview.url = "http://www.ubuntu.com/legal/terms-and-policies/privacy-policy";
                webview.visible = true;
            }
        }
    }

    WebView {
        id: webview
        objectName: "webview"
        anchors.fill: content
        visible: false
    }

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            text: i18n.tr("Next")
            onClicked: {
                diagnostics.setReportCrashes(reportCheck.checked);
                pageStack.next();
            }
        }
    }
}
