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
import Ubuntu.Web 0.2
import ".." as LocalComponents

LocalComponents.Page {
    id: reportingPage
    objectName: "reportingPage"

    title: webview.visible ? i18n.tr("Privacy Policy") : i18n.tr("Help Us Improve")
    forwardButtonSourceComponent: !webview.visible ? forwardButton : null
    customBack: true
    customTitle: webview.visible

    skip: !diagnostics.reportCrashes // skip the page when the system is configured not to report crashes

    onBackClicked: {
        if (webview.visible) {
            webview.visible = false;
        } else {
            pageStack.prev();
        }
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
            checked: diagnostics.reportCrashes
            visible: !webview.visible
            onLinkActivated: {
                webview.url = "http://www.ubuntu.com/legal/terms-and-policies/privacy-policy";
                webview.visible = true;
            }
        }

        WebView {
            id: webview
            objectName: "webview"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: -leftMargin
            anchors.rightMargin: -rightMargin
            height: parent.height
            visible: false
        }
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
