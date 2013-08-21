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
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.DownloadDaemonListener 0.1
import ".."
import "../../Components"
import "../../Components/IconUtil.js" as IconUtil

DashPreview {
    id: root

    signal sendUserReview(string review)

    title: root.previewData.title

    header: ListView {
        spacing: units.gu(1)
        orientation: ListView.Horizontal
        height: units.gu(22)
        anchors {
            left: parent.left
            right: parent.right
            margins: units.gu(1)
        }
        model: previewData.infoMap["more-screenshots"] != null ? previewData.infoMap["more-screenshots"].value : [previewData.image]

        delegate: UbuntuShape {
            id: shape
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            width: units.gu(12)
            radius: "medium"
            borderSource: ""
            image: Image {
                asynchronous: true
                sourceSize { width: shape.width; height: shape.height }
                source: modelData ? modelData : ""
                fillMode: Image.PreserveAspectCrop
            }
        }
    }

    Component {
        id: buttonsComponent

        GridView {
            id: buttonsGrid
            objectName: "gridButtons"

            property int numOfRows: (count + 1) / 2
            property int spacing: units.gu(1)
            height: Math.max(units.gu(5), units.gu(5)*numOfRows + spacing*(numOfRows - 1))

            interactive: false
            cellWidth: Math.max(units.gu(9), width / 2)
            cellHeight: buttonHeight + spacing
            property int buttonWidth: count > 1 ? Math.max(0, width / 2 - spacing) : width
            property int buttonHeight: units.gu(5)

            delegate: Button {
                width: Math.max(units.gu(4), buttonsGrid.buttonWidth)
                height: buttonsGrid.buttonHeight
                color: Theme.palette.selected.foreground
                text: modelData.displayName
                iconSource: modelData.iconHint
                iconPosition: "right"
                onClicked: root.previewData.execute(modelData.id, { })
            }
        }
    }

    Component {
        id: progressComponent

        ProgressBar {
            id: progressBar
            objectName: "progressBar"
            value: 0
            maximumValue: 100
            height: units.gu(5)

            property var model

            DownloadTracker {
                service: "com.canonical.applications.Downloader"
                dbusPath: root.previewData.infoMap["progressbar_source"] ? root.previewData.infoMap["progressbar_source"].value : ""

                onProgress: {
                    var percentage = parseInt(received * 100 / total);
                    progressBar.value = percentage;
                }

                onFinished: {
                    root.previewData.execute(progressBar.model[0].id, { })
                }
            }

        }
    }

    buttons: Loader {
        anchors {
            left: parent.left
            right: parent.right
        }

        sourceComponent: root.previewData.infoMap["show_progressbar"] ? progressComponent : buttonsComponent

        onLoaded: {
            item.model = root.previewData.actions;
        }
    }

    body: Column {
        spacing: units.gu(1)

        AppInfo {
            objectName: "appInfo"
            anchors { left: parent.left; right: parent.right }

            appName: root.previewData.title
            icon: IconUtil.from_gicon(root.previewData.appIcon)
            rating: Math.round(root.previewData.rating * 10)
            reviews: root.previewData.numRatings
            rated: root.previewData.infoMap["rated"] ? root.previewData.infoMap["rated"].value : 0
        }

        Label {
            anchors { left: parent.left; right: parent.right }
            text: root.previewData.description
            fontSize: "medium"
            color: Theme.palette.selected.backgroundText
            opacity: .6
            wrapMode: Text.WordWrap
            style: Text.Raised
            styleColor: "black"
        }

        Column {
            visible: root.previewData.rating >= 0
            anchors { left: parent.left; right: parent.right }
            spacing: parent.spacing

            ListItem.ThinDivider { }

            Item {
                anchors { left: parent.left; right: parent.right }
                height: rateLabel.height

                Label {
                    id: rateLabel
                    fontSize: "medium"
                    color: "white"
                    style: Text.Raised
                    styleColor: "black"
                    opacity: .9
                    text: i18n.tr("Rate this")

                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }

                // FIXME these need to be made interactive and connected to the scope
                RatingStars {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            ListItem.ThinDivider { }

            AppReviews {
                objectName: "appReviews"
                anchors { left: parent.left; right: parent.right }

                model: root.previewData.infoMap["comments"] ? root.previewData.infoMap["comments"].value : undefined

                onSendReview: root.sendUserReview(review);
            }
        }
    }
}
