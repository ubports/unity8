/*
 * This file is part of system-settings
 *
 * Copyright (C) 2016 Canonical Ltd.
 *
 * Contact: Jonas G. Drange <jonas.drange@canonical.com>
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
 *
 */

import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItems
import Ubuntu.Components.Themes 1.3
import Ubuntu.SystemSettings.Update 1.0

ListItem {
    id: update

    property int updateState // This is an Update::State
    property int kind // This is an Update::Kind
    property real size
    property string version
    property string downloadId
    property date updatedAt
    property bool launchable: false

    property alias name: nameLabel.text
    property alias error: errorElementDetail.text
    property alias iconUrl: icon.source
    property alias progress: progressBar.value

    signal retry()
    signal download()
    signal pause()
    signal resume()
    signal install()
    signal launch()

    height: layout.height + (divider.visible ? divider.height : 0)
    Behavior on height {
        animation: UbuntuNumberAnimation {}
    }

    SlotsLayout {
        id: layout
        mainSlot: ColumnLayout {
            spacing: units.gu(1)
            // Width the parent, minus the icon and some padding
            width: parent.width - (icon.width + (layout.padding.top * 3))

            RowLayout {
                spacing: units.gu(2)

                Label {
                    id: nameLabel
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideMiddle
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                Button {
                    id: button
                    objectName: "updateButton"
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    visible: {
                        switch (updateState) {
                        case Update.StateInstalled:
                            return launchable;
                        default:
                            return true;
                        }
                    }
                    enabled: {
                        switch(updateState) {
                        case Update.StateAvailable:
                        case Update.StateDownloading:
                        case Update.StateDownloadingAutomatically:
                        case Update.StateDownloadPaused:
                        case Update.StateAutomaticDownloadPaused:
                        case Update.StateInstallPaused:
                        case Update.StateDownloaded:
                        case Update.StateFailed:
                            return true;

                        // Enabled if installed and a click app (can launch).
                        case Update.StateInstalled:
                            return kind === Update.KindClick;

                        case Update.StateInstalling:
                        case Update.StateInstallingAutomatically:
                        case Update.StateUnavailable:
                        case Update.StateInstallFinished:
                        case Update.StateQueuedForDownload:
                        case Update.StateUnknown:
                        default:
                            return false;
                        }
                    }
                    text: {
                        switch(updateState) {
                        case Update.StateUnknown:
                        case Update.StateUnavailable:
                        case Update.StateFailed:
                            return i18n.tr("Retry");

                        case Update.StateAvailable:
                        case Update.StateQueuedForDownload:
                            if (update.kind === Update.KindClick) {
                                return i18n.tr("Update");
                            } else {
                                return i18n.tr("Download");
                            }

                        case Update.StateDownloadPaused:
                        case Update.StateAutomaticDownloadPaused:
                        case Update.StateInstallPaused:
                                return i18n.tr("Resume");

                        case Update.StateDownloading:
                        case Update.StateDownloadingAutomatically:
                        case Update.StateInstalling:
                        case Update.StateInstallingAutomatically:
                        case Update.StateInstallFinished:
                            return i18n.tr("Pause");

                        case Update.StateDownloaded:
                            if (kind === Update.KindImage) {
                                return i18n.tr("Install…");
                            } else {
                                return i18n.tr("Install");
                            }

                        case Update.StateInstalled:
                            return i18n.tr("Open");

                        default:
                            console.error("Unknown update state", updateState);
                        }
                    }

                    onClicked: {
                        switch (updateState) {

                        // Retries.
                        case Update.StateUnknown:
                        case Update.StateUnavailable:
                        case Update.StateFailed:
                            update.retry();
                            break;

                        case Update.StateDownloadPaused:
                        case Update.StateAutomaticDownloadPaused:
                        case Update.StateInstallPaused:
                            update.resume();
                            break;

                        case Update.StateAvailable:
                            if (kind === Update.KindClick) {
                                update.install();
                            } else {
                                update.download();
                            }
                            break;

                        case Update.StateDownloaded:
                                update.install();
                                break;

                        case Update.StateDownloading:
                        case Update.StateDownloadingAutomatically:
                        case Update.StateInstalling:
                        case Update.StateInstallingAutomatically:
                            update.pause();
                            break;

                        case Update.StateInstalled:
                            update.launch();
                            break;
                        }
                    }
                } // Button
            } // Name/button RowLayout

            RowLayout {
                spacing: units.gu(2)

                Label {
                    id: downloadLabel
                    objectName: "updateDownloadLabel"

                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                    visible: text !== ""

                    fontSize: "small"
                    text: {
                        switch (updateState) {

                        case Update.StateInstalling:
                        case Update.StateInstallingAutomatically:
                        case Update.StateInstallPaused:
                            return i18n.tr("Installing");

                        case Update.StateInstallPaused:
                        case Update.StateDownloadPaused:
                            return i18n.tr("Paused");

                        case Update.StateQueuedForDownload:
                            return i18n.tr("Waiting to download");

                        case Update.StateDownloading:
                            return i18n.tr("Downloading");

                        default:
                            return "";
                        }
                    }
                }

                Label {
                    id: statusLabel
                    objectName: "updateStatusLabel"

                    visible: text !== ""
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    Layout.fillWidth: true

                    horizontalAlignment: Text.AlignRight
                    fontSize: "small"

                    text: {
                        switch (updateState) {
                        case Update.StateAvailable:
                            return Utilities.formatSize(size);

                        case Update.StateDownloading:
                        case Update.StateDownloadingAutomatically:
                        case Update.StateDownloadPaused:
                        case Update.StateAutomaticDownloadPaused:
                            var down = Utilities.formatSize((size / 100) * progress);
                            var left = Utilities.formatSize(size);
                            if (progress > 100) {
                                return left;
                            } else {
                                /* TRANSLATORS: %1 is the human readable amount
                                of bytes downloaded, and %2 is the total to be
                                downloaded. */
                                return i18n.tr("%1 of %2").arg(down).arg(left);
                            }

                        case Update.StateDownloaded:
                            return i18n.tr("Downloaded");

                        case Update.StateInstallFinished:
                            return i18n.tr("Installed");

                        case Update.StateInstalled:
                            /* TRANSLATORS: %1 is the date at which this
                            update was applied. */
                            return i18n.tr("Updated %1").arg(
                                updatedAt.toLocaleDateString(Qt.locale(), "d MMMM")
                            );
                        default:
                            return "";
                        }
                    }

                    /* Seems AlignRight causes a rendering issue that can be
                    fixed by doing an explicit doLayout. */
                    Component.onCompleted: doLayout()
                }
            }

            Column {
                id: error
                objectName: "updateError"
                spacing: units.gu(1)
                height: childrenRect.height
                Layout.fillWidth: true
                visible: errorElementDetail.text

                Label {
                    id: errorElementTitle
                    text: i18n.tr("Update failed")
                    color: UbuntuColors.red
                }

                Label {
                    id: errorElementDetail
                    anchors { left: parent.left; right: parent.right }
                    fontSize: "small"
                    wrapMode: Text.WrapAnywhere
                }
            } // Error column

            ProgressBar {
                id: progressBar
                objectName: "updateProgressbar"

                visible: {
                    switch (updateState) {
                    case Update.StateQueuedForDownload:
                    case Update.StateDownloading:
                    case Update.StateDownloadPaused:
                    case Update.StateInstalling:
                    case Update.StateInstallPaused:
                        return true;

                    default:
                        return false;
                    }
                }
                Layout.maximumHeight: units.gu(0.5)
                Layout.fillWidth: true
                indeterminate: update.progress < 0 || update.progress > 100
                minimumValue: 0
                maximumValue: 100
                showProgressPercentage: false

                Behavior on value {
                    animation: UbuntuNumberAnimation {}
                }
            } // Progress bar
        } // Layout for the rest of the stuff

        Item {
            SlotsLayout.position: SlotsLayout.Leading;
            width: units.gu(4)
            height: width

            Image {
                id: icon
                visible: kind === Update.KindImage && !fallback.visible
                anchors.fill: parent
                asynchronous: true
                smooth: true
                mipmap: true
            }

            UbuntuShape {
                id: shape
                visible: kind !== Update.KindImage && !fallback.visible
                anchors.fill: parent
                source: icon
            }

            Image {
                id: fallback
                visible: icon.status === Image.Error
                source : Qt.resolvedUrl("/usr/share/icons/suru/apps/scalable/ubuntu-logo-symbolic.svg")
                anchors.fill: parent
                asynchronous: true
                smooth: true
                mipmap: true
            }
        }
    }
}
