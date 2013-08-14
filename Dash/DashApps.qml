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
import Utils 0.1
import "../Components"
import "../Components/ListItems"
import "../Applications"
import "Apps"

GenericScopeView {
    id: scopeView

    // FIXME: a way to aggregate these models would be ideal
    property var mainStageApplicationsModel: shell.applicationManager.mainStageApplications
    property var sideStageApplicationModel: shell.applicationManager.sideStageApplications

    SearchableResultModel {
        id: appsAvailableForDownloadModel

        model: AppsAvailableForDownloadModel {}
        filterRole: 3
        searchQuery: scopeView.scope.searchQuery
    }

    ListModel {
        id: dummyVisibilityModifier

        ListElement { name: "running-apps" }
    }

    SortFilterProxyModel {
        id: runningApplicationsModel

        property var firstModel: mainStageApplicationsModel
        property var secondModel: sideStageApplicationModel
        property bool canEnableTerminationMode: scopeView.isCurrent

        model: dummyVisibilityModifier
        filterRole: 0
        filterRegExp: invertMatch ? ((mainStageApplicationsModel.count === 0 &&
                                      sideStageApplicationModel.count === 0) ? RegExp("running-apps") : RegExp("")) : RegExp("disabled")
        invertMatch: scopeView.scope.searchQuery.length == 0
    }

    onScopeChanged: {
        scopeView.scope.categories.overrideResults("recent", runningApplicationsModel);
        scopeView.scope.categories.overrideResults("more", appsAvailableForDownloadModel);
    }

    OpenEffect {
        id: effect
        anchors {
            fill: parent
            bottomMargin: -bottomOverflow
        }
        sourceItem: categoryView

        enabled: gap > 0.0

        topGapPx: (1 - gap) * positionPx
        topOpacity: (1 - gap * 1.2)
        bottomGapPx: positionPx + gap * (targetBottomGapPx - positionPx)
        bottomOverflow: units.gu(20)
        bottomOpacity: 1 - (gap * 0.8)

        property int targetBottomGapPx: height - units.gu(8) - bottomOverflow
        property real gap: previewLoader.open ? 1.0 : 0.0

        Behavior on gap {
            NumberAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
                onRunningChanged: {
                    if (!previewLoader.open && !running) {
                        previewLoader.onScreen = false
                    }
                }
            }
        }
    }

    Connections {
        target: scopeView.scope
        onPreviewReady: {
            previewLoader.previewData = preview
            previewLoader.open = true
        }
    }

    Connections {
        ignoreUnknownSignals: true
        target: previewLoader.valid ? previewLoader.item : null
        onClose: {
            previewLoader.open = false
        }
    }

    PreviewDelegateMapper {
        id: previewDelegateMapper
    }

    Loader {
        id: previewLoader
        property var previewData
        height: effect.bottomGapPx - effect.topGapPx
        anchors {
            top: parent.top
            topMargin: effect.topGapPx
            left: parent.left
            right: parent.right
        }
        source: onScreen ? previewDelegateMapper.map("preview-application") : ""

        property bool open: false
        property bool onScreen: false
        property bool valid: item !== null

        onOpenChanged: {
            if (open) {
                onScreen = true
            }
        }

        onLoaded: {
            item.previewData = previewLoader.previewData
        }
    }

    // TODO: Move as InverseMouseArea to DashPreview
    MouseArea {
        enabled: previewLoader.onScreen
        anchors {
            fill: parent
            topMargin: effect.bottomGapPx
        }
        onClicked: {
            previewLoader.open = false;
        }
    }
}
