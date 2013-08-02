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
            Component.onCompleted: if (categoryId == "installed") scopeView.installedModel = Qt.binding(function() { return model.results; });
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
            property var loader: loader
            // Needed because of the GridView.onRemove anim in Tile.qml
            // TODO see how can we do away without the clip (i.e. not run the animation if we are collapsing)
            clip: true 

            Loader {
                id: loader
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
                            shell.activateApplication(data);
                        }

                        item.model = Qt.binding(function() { return categoryModels[modelName]; });
                        item.clicked.connect(activateApplication);

                    }
                }
            }
        }

        sectionProperty: "category"
        sectionDelegate: Header {
            width: categoryView.width
            text: categoryListModel.getCategory(section)
            onClicked: {
                var obj = categoryView.item(delegateIndex)
                if (obj && obj.loader.item.expandable) {
                    obj.loader.item.filter = !obj.loader.item.filter
                    categoryView.maximizeVisibleArea(delegateIndex);
                }
            }
        }
        pageHeader: PageHeader {
            id: pageHeader
            width: categoryView.width
            text: i18n.tr("Apps")
            searchEntryEnabled: true
            searchHistory: scopeView.searchHistory
        }
    }
}
