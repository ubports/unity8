/*
 * Copyright (C) 2016 Canonical, Ltd.
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
import QtMultimedia 5.0
import Ubuntu.Components 1.3
import Ubuntu.Thumbnailer 0.1
import "PreviewSingleton"
import "../../Components"
import "../../Components/MediaServices"

/*! \brief Preview widget for video.

    This widget shows video contained in widgetData["source"],
    with a placeholder screenshot specified by widgetData["screenshot"].
 */

PreviewWidget {
    id: root
    implicitWidth: units.gu(35)
    implicitHeight: services.height

    singleColumnMarginless: true
    orientationLock: services.fullscreen

    property alias rootItem: services.rootItem
    readonly property string widgetExtraDataKey: services.source.toString()

    onWidgetExtraDataKeyChanged: {
        root.restorePlaybackState();
    }

    function seek() {
        services.mediaPlayer.seek(services.initialPosition);
        services.initialPosition = -1;
    }

    function storePlaybackState() {
        if ((services.mediaPlayer.duration - services.mediaPlayer.position) < 1000) {
            // we're at the end of the video
            PreviewSingleton.widgetExtraData[widgetExtraDataKey] = 0;
        } else {
            PreviewSingleton.widgetExtraData[widgetExtraDataKey] = services.mediaPlayer.position;
        }
    }

    function restorePlaybackState() {
        if (PreviewSingleton.widgetExtraData[widgetExtraDataKey] > 0) {
            services.initialPosition = PreviewSingleton.widgetExtraData[widgetExtraDataKey];
        }
    }

    MediaServices {
        id: services
        objectName: "services"
        width: parent.width

        actions: sharingAction
        context: "video"
        sourceData: widgetData
        fullscreen: false
        maximumEmbeddedHeight: rootItem.height / 2

        property int initialPosition: -1

        readonly property var mediaPlayer: footer.mediaPlayer
        readonly property url source: mediaPlayer.source
        readonly property int position: mediaPlayer.position

        onClose: fullscreen = false

        onPositionChanged: {
            if (mediaPlayer.playbackState === MediaPlayer.StoppedState) return;
            root.storePlaybackState();
        }

        Connections {
            target: services.mediaPlayer
            ignoreUnknownSignals: true
            onPlaying: {
                // at the first playback of the file, do a seek()
                if (services.initialPosition > 0) root.seek();
            }
        }

        Action {
            id: sharingAction
            iconName: "share"
            visible: sharingPicker.active
            onTriggered: sharingPicker.showPeerPicker()
        }
    }

    SharingPicker {
        id: sharingPicker
        objectName: "sharingPicker"
        shareData: widgetData["share-data"]
    }
}
