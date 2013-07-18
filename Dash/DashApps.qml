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
import "Apps"

ScopeView {
    id: scopeView

    // FIXME: a way to aggregate these models would be ideal
    property var mainStageApplicationsModel: shell.applicationManager.mainStageApplications
    property var sideStageApplicationModel: shell.applicationManager.sideStageApplications

    onMovementStarted: categoryView.showHeader()
    onPositionedAtBeginning: {
        if (isCurrent) {
            categoryView.positionAtBeginning()
        }
    }

    onIsCurrentChanged: {
        pageHeader.resetSearch();
    }

    Binding {
        target: scopeView.scope
        property: "searchQuery"
        value: pageHeader.searchQuery
    }

    Connections {
        target: panel
        onSearchClicked: if (isCurrent) {
            pageHeader.triggerSearch()
            categoryView.showHeader()
        }
    }

    ListModel {
        id: categoryListModel
        // specifies app categories, type of delegate and model used in each category
        ListElement { category: "Running apps";           component: "Apps/RunningApplicationsGrid.qml"; modelName: "RunningApplicationsModel" }
        ListElement { category: "Frequently used";        component: "Apps/ApplicationsFilterGrid.qml";  modelName: "FrequentlyUsedAppsModel" }
        ListElement { category: "Installed";              component: "Apps/ApplicationsFilterGrid.qml";  modelName: "InstalledApplicationsModel" }
        ListElement { category: "Available for download"; component: "Apps/ApplicationsFilterGrid.qml";  modelName: "AppsAvailableForDownloadModel" }
        function getCategory(category1) {
            if (category1 === "Running apps") {
                return i18n.tr("Running apps");
            }
            if (category1 === "Frequently used") {
                return i18n.tr("Frequently used");
            }
            if (category1 === "Installed") {
                return i18n.tr("Installed");
            }
            if (category1 === "Available for download") {
                return i18n.tr("Available for download");
            }
            return ""
        }
    }

    FrequentlyUsedAppsModel { id: frequentlyUsedAppsModel }
    AppsAvailableForDownloadModel { id: appsAvailableForDownloadModel }

    // FIXME this should not be needed, the backend should handle all that itself
    property var installedModel: null

    Repeater {
        model: scopeView.scope.categories

        delegate: Item {
            Component.onCompleted: if (index == 3) scopeView.installedModel = Qt.binding(function() { return model.results; });
        }
    }

    property var categoryModels: {
        "FrequentlyUsedAppsModel": frequentlyUsedAppsModel,
        "InstalledApplicationsModel": installedModel,
        "AppsAvailableForDownloadModel": appsAvailableForDownloadModel,
    }

    ScopeListView {
        id: categoryView
        anchors.fill: parent
        model: SortFilterProxyModel {
            model: categoryListModel
            filterRole: 0 // 0 == modelName
            // FIXME: need to use invertMatch here, otherwise the filter won't update correctly
            // if filterRegExp is set before invertMatch. Bug in SortFilterProxyModel?
            filterRegExp: invertMatch ? ((mainStageApplicationsModel.count === 0
                           && sideStageApplicationModel.count === 0) ? RegExp("RunningApplicationsModel") : RegExp("")) :
                           RegExp("InstalledApplicationsModel")
            invertMatch: pageHeader.searchQuery.length == 0
        }

        onAtYEndChanged: if (atYEnd) endReached()
        onMovingChanged: if (moving && atYEnd) endReached()

        delegate: Base {
            id: container
            highlightWhenPressed: false

            Loader {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }
                source: component
                onLoaded: {
                    if (modelName == "RunningApplicationsModel") {
                        item.firstModel = mainStageApplicationsModel
                        item.secondModel = sideStageApplicationModel
                        item.canEnableTerminationMode =
                            Qt.binding(function() { return isCurrent; })
                    } else {
                        function activateApplication(index, data) {
                            //Check somehow if the app is not installed
                            // IF NOT INSTALLED:
                            //previewLoader.previewData = data;
                            //previewLoader.open = true;
                            //effect.positionPx = mapToItem(categoryView, 0, itemY).y;
                            // IF INSTALLED:
                            shell.activateApplication(data);
                        }

                        item.model = Qt.binding(function() { return categoryModels[modelName]; });
                        item.clicked.connect(activateApplication);

                    }
                }
            }

            ListView.onRemove: SequentialAnimation {
                PropertyAction {
                    target: container; property: "ListView.delayRemove"; value: true
                }
                NumberAnimation {
                    target: container; property: "height"; to: 0;
                    duration: 250; easing.type: Easing.InOutQuad
                }
                PropertyAction {
                    target: container; property: "ListView.delayRemove"; value: false
                }
            }
        }

        sectionProperty: "category"
        sectionDelegate: Header {
            width: categoryView.width
            text: categoryListModel.getCategory(section)
        }
        pageHeader: PageHeader {
            id: pageHeader
            width: categoryView.width
            text: i18n.tr("Apps")
            searchEntryEnabled: true
            searchHistory: scopeView.searchHistory
        }
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
        source: onScreen ? previewDelegateMapper.map("preview-app") : ""

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
