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
import Ubuntu.DownloadDaemonListener 0.1

/*! \brief Preview widget for a progress bar.
 *
 *  It feeds itself from the source determined in widgetData["source"]
 *  At the moment we only support the dbus source defined
 *  by source["dbus-name"] and source["dbus-object"]
 */

PreviewWidget {
    id: root

    implicitHeight: progressBar.implicitHeight
    implicitWidth: progressBar.implicitWidth

    ProgressBar {
        id: progressBar
        objectName: "progressBar"
        anchors.right: parent.right
        value: 0
        maximumValue: 100
        implicitHeight: units.gu(4)
        height: parent.height
        width: (root.width - units.gu(1)) / 2

        property var source: widgetData["source"]
        // TODO Eventually we will need to support more sources other
        // than DownloadTracker via dbus so we'll need a Loader based on source contents

        DownloadTracker {
            service: progressBar.source["dbus-name"] || ""
            dbusPath: progressBar.source["dbus-object"] || ""

            onProgress: {
                if (total <= 0) {
                    progressBar.indeterminate = true;
                } else {
                    progressBar.indeterminate = false;
                    var percentage = parseInt(received * 100 / total);
                    progressBar.value = percentage;
                }
            }

            onFinished: {
                root.triggered(widgetId, "finished", widgetData)
            }

            onError: {
                root.triggered(widgetId, "failed", widgetData)
            }
        }
    }
}
