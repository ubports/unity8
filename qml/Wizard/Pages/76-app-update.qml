/*
 * Copyright (C) 2018 The UBports project
 *
 * Written by: Dalton Durst <dalton@ubports.com>
 *             Marius Gripsgard <marius@ubports.com>
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 3, as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QMenuModel 0.1
import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import Ubuntu.Components.Popups 1.3
import Ubuntu.SystemSettings.Update 1.0
import Wizard 0.1
import ".." as LocalComponents

LocalComponents.Page {
    id: appUpdatePage
    objectName: "appUpdatePage"

    title: i18n.tr("Update Apps")
    forwardButtonSourceComponent: forwardButton

    property bool batchMode: false

    onlyOnUpdate: true

    property int updatesCount: {
        var count = 0;
        count += clickRepeater.count;
        return count;
    }

    function check(force) {
        UpdateManager.check(UpdateManager.CheckClickIgnoreVersion);
    }

    DownloadHandler {
        id: downloadHandler
        updateModel: UpdateManager.model
    }

    Flickable {
        id: scrollWidget
        anchors {
            fill: content
            leftMargin: parent.leftMargin
            rightMargin: parent.rightMargin
        }
        clip: true
        contentHeight: scrollWidgetContent.height
        boundsBehavior: (contentHeight > scrollWidgetContent.height) ?
                        Flickable.DragAndOvershootBounds :
                        Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick

        Column {
            id: scrollWidgetContent
            anchors {
              left: parent.left
              right: parent.right
            }

            GlobalUpdateControls {
                id: g
                objectName: "global"
                anchors { left: parent.left; right: parent.right }

                height: hidden ? 0 : units.gu(8)
                clip: true
                status: UpdateManager.status
                batchMode: appUpdatePage.batchMode
                updatesCount: appUpdatePage.updatesCount
                online: root.connected
                onStop: UpdateManager.cancel()

                onRequestInstall: {
                    install();
                }
                onInstall: {
                    appUpdatePage.batchMode = true
                    postClickBatchHandler.target = appUpdatePage;
                }
            }

            Rectangle {
                id: overlay
                objectName: "overlay"
                anchors {
                    left: parent.left
                    leftMargin: units.gu(2)
                    right: parent.right
                    rightMargin: units.gu(2)
                }
                visible: placeholder.text
                color: theme.palette.normal.background
                height: units.gu(10)

                Label {
                    id: placeholder
                    objectName: "overlayText"
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: {
                        var s = UpdateManager.status;
                        if (!root.connected) {
                            return i18n.tr("This device is not connected to the internet.") + " " +
                                    i18n.tr("Use the OpenStore app to check for updates once connected.");
                        } else if (s === UpdateManager.StatusIdle && updatesCount === 0) {
                            return i18n.tr("Software is up to date");
                        } else if (s === UpdateManager.StatusServerError ||
                                s === UpdateManager.StatusNetworkError) {
                            return i18n.tr("The update server is not responding.") + " " +
                                    i18n.tr("Use the OpenStore app to check for updates once connected.");
                        }
                        return "";
                    }
                }
            }

            Column {
                id: clickUpdatesCol
                objectName: "clickUpdates"
                anchors { left: parent.left; right: parent.right }
                visible: {
                    var s = UpdateManager.status;
                    var haveUpdates = clickRepeater.count > 0;
                    switch (s) {
                    case UpdateManager.StatusCheckingImageUpdates:
                    case UpdateManager.StatusIdle:
                        return haveUpdates && root.connected;
                    }
                    return false;
                }

                Repeater {
                    id: clickRepeater
                    model: UpdateManager.clickUpdates

                    delegate: ClickUpdateDelegate {
                        objectName: "clickUpdatesDelegate" + index
                        width: clickUpdatesCol.width
                        updateState: model.updateState
                        progress: model.progress
                        version: remoteVersion
                        size: model.size
                        name: title
                        iconUrl: model.iconUrl
                        kind: model.kind
                        error: model.error
                        signedUrl: signedDownloadUrl

                        onInstall: downloadHandler.createDownload(model);
                        onPause: downloadHandler.pauseDownload(model)
                        onResume: downloadHandler.resumeDownload(model)
                        onRetry: {
                            /* This creates a new signed URL with which we can
                            retry the download. See onSignedUrlChanged. */
                            UpdateManager.retry(model.identifier,
                                            model.revision);
                        }

                        onSignedUrlChanged: {
                            // If we have a signedUrl, user intend to retry.
                            if (signedUrl) {
                                downloadHandler.retryDownload(model);
                            }
                        }

                        Connections {
                            target: g
                            onInstall: install()
                        }

                        /* If we a downloadId, we expect UDM to restore it
                        after some time. Workaround for lp:1603770. */
                        Timer {
                            id: downloadTimeout
                            interval: 30000
                            running: true
                            onTriggered: {
                                var s = updateState;
                                if (model.downloadId
                                    || s === Update.StateQueuedForDownload
                                    || s === Update.StateDownloading) {
                                    downloadHandler.assertDownloadExist(model);
                                }
                            }
                        }
                    }
                }
            }
        } // Column inside flickable
    } // Flickable

    Connections {
        id: postClickBatchHandler
        ignoreUnknownSignals: true
        target: null
        onUpdatesCountChanged: {
            if (target.updatesCount === 0) {
                appUpdatePage.batchMode = false;
                target = null;
            }
        }
    }

    Component.onCompleted: check()

    Component {
        id: forwardButton
        LocalComponents.StackButton {
            text: {
                var s = UpdateManager.status;
                if (s === UpdateManager.StatusIdle && updatesCount === 0) {
                    return i18n.tr("Next");
                } else if (s === UpdateManager.StatusCheckingClickUpdates) {
                    return i18n.tr("Please wait...")
                } else {
                    return i18n.tr("Skip");
                }
            }
            onClicked: pageStack.next()
        }
    }
}
